# frozen_string_literal: true
module Zizia
  class HyraxMetadataOnlyUpdater
    attr_accessor :depositor,
                  :existing_record,
                  :update_record,
                  :based_near_attributes,
                  :csv_import_detail

    def initialize(csv_import_detail:,
                   existing_record:,
                   update_record:,
                   attrs:)
      @csv_import_detail = csv_import_detail
      @depositor = ::User.find(csv_import_detail.depositor_id)
      @update_record = update_record
      @existing_record = existing_record
      @attrs = attrs
    end

    def attrs
      @attrs.reject { |k, _v| k == :uploaded_files }
    end

    def actor_stack
      terminator = Hyrax::Actors::Terminator.new
      Zizia::MetadataOnlyStack.build_stack.build(terminator)
    end

    def started
      Rails.logger.info "[zizia] event: record_update_started, batch_id: #{csv_import_detail.batch_id}, collection_id: #{csv_import_detail.collection_id}, #{csv_import_detail.deduplication_field}: #{update_record.respond_to?(csv_import_detail.deduplication_field) ? update_record.send(csv_import_detail.deduplication_field.deduplication_field) : update_record}"
    end

    def succeeded
      Rails.logger.info "[zizia] event: record_updated, batch_id: #{csv_import_detail.batch_id}, record_id: #{csv_import_detail.existing_record.id}, collection_id: #{csv_import_detail.collection_id}, #{csv_import_detail.deduplication_field}: #{existing_record.respond_to?(csv_import_detail.deduplication_field) ? existing_record.send(csv_import_detail.deduplication_field) : existing_record}"
    end

    def failed(attr)
      Rails.logger.error "[zizia] event: validation_failed, batch_id: #{csv_import_detail.batch_id}, collection_id: #{csv_import_detail.collection_id}, attribute: #{attr.capitalize}, message: #{msg}, record_title: record_title: #{attrs[:title] ? attrs[:title] : attrs}"
    end

    def create_actor_env
      Hyrax::Actors::Environment.new(existing_record, ::Ability.new(depositor), attrs)
    end

    def update
      if actor_stack.update(create_actor_env)
        csv_import_detail.success_count += 1
      else
        existing_record.errors.each_key do |attr, _msg|
          failed(attr)
        end
        csv_import_detail.failure_count += 1
      end
      csv_import_detail.save
    end
  end
end
