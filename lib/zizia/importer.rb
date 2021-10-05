# frozen_string_literal: true

module Zizia
  ##
  # The chief entry point for bulk import of records. `Importer` accepts a
  # {Parser} on initialization and iterates through its {Parser#records}, importing
  # each using a given {RecordImporter}.
  #
  # @example Importing in bulk from a CSV file
  #   parser = Zizia::Parser.for(file: File.new('path/to/import.csv'))
  #
  #   Zizia::Importer.new(parser: parser).import if parser.validate
  #
  class Importer
    extend Forwardable

    ##
    # @!attribute [rw] parser
    #   @return [Parser]
    # @!attribute [rw] record_importer
    #   @return [RecordImporter]
    attr_accessor :parser, :record_importer

    ##
    # @!method records()
    #   @see Parser#records
    def_delegator :parser, :records, :records

    ##
    # @param parser          [Parser] The parser to use as the source for import
    #   records.
    # @param record_importer [RecordImporter] An object to handle import of
    #   each record
    def initialize(parser:, record_importer: RecordImporter.new)
      self.parser          = parser
      self.record_importer = record_importer
    end

    # Do not attempt to run an import if there are no records. Instead, just write to the log.
    def no_records_message
      Rails.logger.error "[zizia] event: empty_import, batch_id: #{record_importer.batch_id}"
    end

    ##
    # Import each record in {#records}.
    #
    # @return [void]
    def import
      no_records_message && return unless records.count.positive?
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      Rails.logger.info "[zizia] event: start_import, batch_id: #{record_importer.batch_id}, expecting to import #{records.count} records."
      record_importer.import_all_records(records)
      # records.each { |record| record_importer.import(record: record) }
      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      elapsed_time = end_time - start_time
      Rails.logger.info "[zizia] event: finish_import, batch_id: #{record_importer.batch_id}, successful_record_count: #{record_importer.success_count}, failed_record_count: #{record_importer.failure_count}, elapsed_time: #{elapsed_time}, elapsed_time_per_record: #{elapsed_time / records.count}"
    end
  end
end
