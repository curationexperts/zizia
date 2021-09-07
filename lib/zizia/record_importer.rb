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

    def import_type(record)
      raise 'No curation_concern found for import' unless
        defined?(Hyrax) && Hyrax&.config&.curation_concerns&.any?
      if record.object_type
        case record.object_type.first&.downcase
        when "c"
          Collection
        else
          Hyrax.config.curation_concerns.first
        end
      else
        Hyrax.config.curation_concerns.first
      end
    end

    private

      def process_attrs(record:)
        attrs = record.attributes
        # Ensure nothing is passed in the object_type field, since this is internal to Zizia
        # and will eventually determine what type of object is created
        attrs.delete(:object_type)
        attrs
      end

      def create_for(record:)
        Rails.logger.info "[zizia] Creating record: #{record.respond_to?(:title) ? record.title : record}."

        created = import_type(record).create(process_attrs(record: record))

        Rails.logger.info "[zizia] Record created at: #{created.id}"
      end
  end
end
