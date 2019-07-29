# frozen_string_literal: true

module Zizia
  class StartCsvImportJob < ApplicationJob
    queue_as :default

    def perform(csv_import_id)
      csv_import = CsvImport.find csv_import_id
      log_stream = Zizia.config.default_info_stream
      log_stream << "Starting import with batch ID: #{csv_import_id}"
      importer = ModularImporter.new(csv_import)
      importer.import
    end
  end
end
