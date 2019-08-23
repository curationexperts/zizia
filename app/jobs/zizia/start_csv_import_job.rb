# frozen_string_literal: true

module Zizia
  class StartCsvImportJob < ApplicationJob
    queue_as :default

    def perform(csv_import_id)
      csv_import = CsvImport.find csv_import_id
      Rails.logger.info "[zizia] Starting import with batch ID: #{csv_import_id}"
      importer = ModularImporter.new(csv_import)
      importer.import
    end
  end
end
