# frozen_string_literal: true

module Zizia
  class RecordImporter
    ##
    # @!attribute [rw] batch_id
    #   @return [String] an optional batch id for this import run
    # @!attribute [rw] success_count
    #   @return [Integer] a count of the records that were successfully created
    # @!attribute [rw] failure_count
    #   @return [Integer] a count of the records that failed import
    attr_accessor :batch_id, :success_count, :failure_count

    ##
    # @param record [ImportRecord]
    #
    # @return [void]
    def import(record:)
      create_for(record: record)
    rescue Faraday::ConnectionFailed, Ldp::HttpError => e
      Rails.logger.error "[zizia] #{e}"
    rescue RuntimeError => e
      Rails.logger.error "[zizia] #{e}"
      raise e
    end

    def import_type
      raise 'No curation_concern found for import' unless
        defined?(Hyrax) && Hyrax&.config&.curation_concerns&.any?

      Hyrax.config.curation_concerns.first
    end

    private

      def create_for(record:)
        Rails.logger.info "[zizia] Creating record: #{record.respond_to?(:title) ? record.title : record}."

        created = import_type.create(record.attributes)

        Rails.logger.info "[zizia] Record created at: #{created.id}"
      end
  end
end
