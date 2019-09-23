# frozen_string_literal: true
module Zizia
  class HyraxMetadataOnlyUpdater
    attr_accessor :depositor,
                  :collection_id,
                  :batch_id,
                  :deduplication_field,
                  :success_count,
                  :failure_count,
                  :existing_record,
                  :update_record,
                  :metadata_only_middleware,
                  :based_near_attributes

    def initialize(csv_import_detail:,
                   existing_record:,
                   update_record:,
                   attrs:)
      @csv_import_detail = csv_import_detail
      @depositor = ::User.find(csv_import_detail.depositor_id)
      @collection_id = csv_import_detail.collection_id
      @batch_id = csv_import_detail.batch_id
      @deduplication_field = csv_import_detail.deduplication_field
      @success_count = csv_import_detail.success_count || 0
      @failure_count = csv_import_detail.failure_count || 0
      @update_record = update_record
      @existing_record = existing_record
      @attrs = attrs.reject { |k, _v| k == :uploaded_files }

      # Build a pared down actor stack that will not re-attach files,
      # or set workflow, or do anything except update metadata.
      terminator = Hyrax::Actors::Terminator.new
      @metadata_only_middleware = Zizia::MetadataOnlyStack.build_stack.build(terminator)
    end

    def update
      Rails.logger.info "[zizia] event: record_update_started, batch_id: #{@batch_id}, collection_id: #{@collection_id}, #{@deduplication_field}: #{@update_record.respond_to?(deduplication_field) ? @update_record.send(deduplication_field) : @update_record}"

      actor_env = Hyrax::Actors::Environment.new(@existing_record, ::Ability.new(@depositor), @attrs)

      if @metadata_only_middleware.update(actor_env)
        Rails.logger.info "[zizia] event: record_updated, batch_id: #{batch_id}, record_id: #{existing_record.id}, collection_id: #{collection_id}, #{deduplication_field}: #{existing_record.respond_to?(deduplication_field) ? existing_record.send(deduplication_field) : existing_record}"
        @success_count += 1
      else
        existing_record.errors.each do |attr, msg|
          Rails.logger.error "[zizia] event: validation_failed, batch_id: #{batch_id}, collection_id: #{collection_id}, attribute: #{attr.capitalize}, message: #{msg}, record_title: record_title: #{attrs[:title] ? attrs[:title] : attrs}"
        end
        @failure_count += 1
      end
      @csv_import_detail.save
    end
  end
end
