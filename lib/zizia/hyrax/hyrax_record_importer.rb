# frozen_string_literal: true
module Zizia
  class HyraxRecordImporter < RecordImporter
    # TODO: Get this from Hyrax config
    DEFAULT_CREATOR_KEY = 'batchuser@example.com'

    attr_accessor :csv_import_detail

    # @!attribute [rw] depositor
    # @return [User]
    attr_accessor :depositor

    # @!attribute [rw] collection_id
    # @return [String] The fedora ID for a Collection.
    attr_accessor :collection_id

    # @!attribute [rw] batch_id
    # @return [String] an id number associated with the process that kicked off this import run
    attr_accessor :batch_id

    # @!attribute [rw] deduplication_field
    # @return [String] if this is set, look for records with a match in this field
    # and update the metadata instead of creating a new record. This will NOT re-import file attachments.
    attr_accessor :deduplication_field

    # @!attribute [rw] success_count
    # @return [String] the number of records this importer has successfully created
    attr_accessor :success_count

    # @!attribute [rw] failure_count
    # @return [String] the number of records this importer has failed to create
    attr_accessor :failure_count

    # @param attributes [Hash] Attributes that come
    #        from the UI or importer rather than from
    #        the CSV/mapper. These are useful for logging
    #        and tracking the output of an import job for
    #        a given collection, user, or batch.
    #        If a deduplication_field is provided, the system will
    #        look for existing works with that field and matching
    #        value and will update the record instead of creating a new record.
    # @example
    #   attributes: { collection_id: '123',
    #                 depositor_id: '456',
    #                 batch_id: '789',
    #                 deduplication_field: 'legacy_id'
    #               }
    def initialize(attributes: {})
      # These attributes are persisted in the CsvImportDetail model
      @csv_import_detail = attributes[:csv_import_detail]
      @deduplication_field = csv_import_detail.deduplication_field
      @collection_id = find_collection_id(csv_import_detail: csv_import_detail, record: nil)
      @batch_id = csv_import_detail.batch_id
      @success_count = csv_import_detail.success_count
      @failure_count = csv_import_detail.failure_count
      find_depositor(csv_import_detail.depositor_id)
    end

    def import_all_records(records)
      @collection_records = records.select { |record| record.object_type == :collection }
      @collection_records.each { |record| import(record: record) }
      @work_records = records.select { |record| record.object_type == :work }
      @file_records = records.select { |record| record.object_type == :file }
      @work_records.each { |record| import(record: record) }
    end

    def find_collection_id(csv_import_detail:, record:)
      if csv_import_detail&.collection_id&.present?
        csv_import_detail.collection_id
      elsif record&.parent
        Collection.where("#{deduplication_field}": record.parent)&.first&.id
      end
    end

    # "depositor" is a required field for Hyrax.  If
    # it hasn't been set, set it to the Hyrax default
    # batch user.
    def find_depositor(user_key)
      user = ::User.find_by_user_key(user_key) if user_key
      user ||= ::User.find(user_key) if user_key
      user ||= ::User.find_or_create_system_user(DEFAULT_CREATOR_KEY)
      self.depositor = user
    end

    ##
    # @param record [ImportRecord]
    # @return [ActiveFedora::Base]
    # Search for any existing records that match on the deduplication_field
    def find_existing_record(record)
      return unless deduplication_field
      return unless record.respond_to?(deduplication_field)
      return if record.mapper.send(deduplication_field).nil?
      return if record.mapper.send(deduplication_field).empty?
      existing_records = import_type(record).where("#{deduplication_field}": record.mapper.send(deduplication_field).to_s)
      raise "More than one record matches deduplication_field #{deduplication_field} with value #{record.mapper.send(deduplication_field)}" if existing_records.count > 1
      existing_records&.first
    end

    ##
    # @param record [ImportRecord]
    #
    # @return [void]
    def import(record:)
      existing_record = find_existing_record(record)
      create_for(record: record) unless existing_record
      update_for(existing_record: existing_record, update_record: record) if existing_record
    rescue Faraday::ConnectionFailed, Ldp::HttpError => e
      Rails.logger.error "[zizia] #{e}"
    rescue RuntimeError => e
      Rails.logger.error "[zizia] #{e}"
      raise e
    end

    # TODO: You should be able to specify the import type in the import
    def import_type(record)
      raise 'No curation_concern found for import' unless
        defined?(Hyrax) && Hyrax&.config&.curation_concerns&.any?
      if record.object_type.present?
        determine_object_type(record.object_type)
      else
        Hyrax.config.curation_concerns.first
      end
    end

    def determine_object_type(object_type)
      case object_type
      when :collection
        Collection
      when :work
        Hyrax.config.curation_concerns.first
      when :file
        FileSet
      else
        raise  "[zizia] Unrecognized object_type: #{object_type_string}"
      end
    end

    # The path on disk where file attachments can be found
    def file_attachments_path
      ENV['IMPORT_PATH'] || '/opt/data'
    end

    # Create a Hyrax::UploadedFile for each file attachment
    # TODO: What if we can't find the file?
    # TODO: How do we specify where the files can be found?
    # @param [Zizia::InputRecord]
    # @return [Array<Hyrax::UploadedFile>] uploaded_files - an array of files to attach
    def create_upload_files(files_to_attach)
      files_to_attach.map do |filename|
        file = File.open(find_file_path(filename))
        uploaded_file = Hyrax::UploadedFile.create(user: depositor, file: file)
        file.close
        uploaded_file
      end
    end

    # @param [Zizia::InputRecord]
    # @return [Array] an array of Hyrax::UploadedFile ids
    def uploaded_files_ids(record)
      return unless record.mapper.respond_to?(:files)
      file_records_to_attach = if @file_records
                                 @file_records.select { |file_rec| file_rec.parent == record.deduplication_key }
                               else
                                 []
                               end
      # Handle object_type=file rows that have one or more file per row
      separate_line_files_to_attach = file_records_to_attach.flat_map { |file_rec| file_rec.mapper.files }
      # Handle a work with a single cell packed with multiple files - e.g. "file1.txt|~|file2.txt|~|file3.txt"
      inline_files_to_attach = record.mapper.files
      files_to_attach = separate_line_files_to_attach + inline_files_to_attach

      return [] if files_to_attach.nil? || files_to_attach.empty?
      create_upload_files(files_to_attach).map(&:id)
    end

    ##
    # Within the directory specified by ENV['IMPORT_PATH'], find the first
    # instance of a file matching the given filename.
    # If there is no matching file, raise an exception.
    # @param [String] filename
    # @return [String] a full pathname to the found file
    def find_file_path(filename)
      filepath = Dir.glob("#{ENV['IMPORT_PATH']}/**/#{filename}").first
      raise "Cannot find file #{filename}... Are you sure it has been uploaded and that the filename matches?" if filepath.nil?
      filepath
    end

    private

      def update_for(existing_record:, update_record:)
        if update_record.object_type == :collection
          collection_updater(existing_record: existing_record, update_record: update_record)
        else
          curation_concern_updater(existing_record: existing_record, update_record: update_record)
        end
      end

      def collection_updater(existing_record:, update_record:)
        attrs = process_collection_attrs(record: update_record)

        case csv_import_detail.update_actor_stack
        when 'HyraxMetadataOnly', 'HyraxDelete'
          # Update Existing Metadata, create new works
          existing_record.update(attrs)
        when 'HyraxOnlyNew'
          return unless existing_record[deduplication_field] != update_record.try(deduplication_field)
          # Ignore Existing Works, new works only
          raise "This has not been implemented yet"
        end
      end

      # Update an existing object using the Hyrax actor stack
      # We assume the object was created as expected if the actor stack returns true.
      # Note that for now the update stack will only update metadata and update collection membership, it will not re-import files.
      def curation_concern_updater(existing_record:, update_record:)
        updater = case csv_import_detail.update_actor_stack
                  when 'HyraxMetadataOnly'
                    Zizia::HyraxMetadataOnlyUpdater.new(csv_import_detail: csv_import_detail,
                                                        existing_record: existing_record,
                                                        update_record: update_record,
                                                        attrs: process_attrs(record: update_record))
                  when 'HyraxDelete'
                    Zizia::HyraxDeleteFilesUpdater.new(csv_import_detail: csv_import_detail,
                                                       existing_record: existing_record,
                                                       update_record: update_record,
                                                       attrs: process_attrs(record: update_record))
                  when 'HyraxOnlyNew'
                    return unless existing_record[deduplication_field] != update_record.try(deduplication_field)
                    Zizia::HyraxDefaultUpdater.new(csv_import_detail: csv_import_detail,
                                                   existing_record: existing_record,
                                                   update_record: update_record,
                                                   attrs: process_attrs(record: update_record))
                  end
        updater.update
      end

      def process_attrs(record:)
        additional_attrs = {
          uploaded_files: uploaded_files_ids(record),
          depositor: depositor.user_key
        }

        attrs = record.attributes.merge(additional_attrs)
        if collection_id
          attrs = attrs.merge(member_of_collections_attributes: { '0' => { id: collection_id } })
        elsif find_collection_id(csv_import_detail: nil, record: record)
          attrs = attrs.merge(member_of_collections_attributes: { '0' => { id: find_collection_id(csv_import_detail: nil, record: record) } })
        end

        # Ensure nothing is passed in the files field,
        # since this is reserved for Hyrax and is where uploaded_files will be attached
        attrs.delete(:files)
        # Ensure nothing is passed in the object_type field, since this is internal to Zizia
        # and will eventually determine what type of object is created
        attrs.delete(:object_type)

        # TODO: in the future we will want to use this identifier to indicate a parent object
        attrs.delete(:parent)

        based_near = attrs.delete(:based_near)
        attrs = attrs.merge(based_near_attributes: Zizia::BasedNearAttributes.new(based_near).to_h) unless based_near.nil? || based_near.empty?
        attrs
      end

      def process_collection_attrs(record:)
        additional_attrs = {
          depositor: depositor.user_key,
          collection_type_gid: Hyrax::CollectionType.find_or_create_default_collection_type.gid
        }
        attrs = record.attributes.merge(additional_attrs)
        # Remove attributes that are not part of Collections
        attrs.delete(:deduplication_key)
        attrs.delete(:files)
        attrs.delete(:object_type)
        # TODO: in the future we will want to use this identifier to indicate a parent object
        attrs.delete(:parent)
        attrs
      end

      def create_collection(record)
        created = Collection.new
        attrs = process_collection_attrs(record: record)
        created.update(attrs)
        created.save!
      end

      def create_curation_concern(record, import_type)
        created = import_type.new
        attrs = process_attrs(record: record)
        actor_env = Hyrax::Actors::Environment.new(created,
                                                   ::Ability.new(depositor),
                                                   attrs)
        if Hyrax::CurationConcern.actor.create(actor_env)
          Rails.logger.info "[zizia] event: record_created, batch_id: #{batch_id}, record_id: #{created.id}, collection_id: #{collection_id}, record_title: #{attrs[:title]&.first}"
          csv_import_detail.success_count += 1
        else
          created.errors.each do |attr, msg|
            Rails.logger.error "[zizia] event: validation_failed, batch_id: #{batch_id}, collection_id: #{collection_id}, attribute: #{attr.capitalize}, message: #{msg}, record_title: record_title: #{attrs[:title] ? attrs[:title] : attrs}"
          end
          csv_import_detail.failure_count += 1
        end
      end

      # TODO: Right now we assume that the parent is a Work, but it would be more generally
      # applicable to let this be any sort of CurationConcern
      def find_parent_work(record)
        parent_work = Work.where("#{deduplication_field}": record.mapper.send(deduplication_field).to_s).first
        return parent_work if parent_work.present?
        raise "[zizia] Parent work for file not found, cannot attach file to work"
      end

      def create_file_set(record)
        work = find_parent_work(record)
        files_to_attach = record.mapper.files
        uploaded_files = create_upload_files(files_to_attach)
        AttachFilesToWorkWithOrderedMembersJob.perform_later(work, uploaded_files)
      end

      # Create an object using the Hyrax actor stack
      # We assume the object was created as expected if the actor stack returns true.
      def create_for(record:)
        Rails.logger.info "[zizia] event: record_import_started, batch_id: #{batch_id}, collection_id: #{collection_id}, record_title: #{record.respond_to?(:title) ? record.title : record}"
        import_type = import_type(record)
        if import_type == Collection
          create_collection(record)
        elsif import_type == FileSet
          create_file_set(record)
        else
          create_curation_concern(record, import_type)
        end
        csv_import_detail.save
      end
  end
end
