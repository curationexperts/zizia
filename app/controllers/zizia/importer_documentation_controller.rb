# frozen_string_literal: true

module Zizia
  class ImporterDocumentationController < ApplicationController
    def guide; end

    def csv
      send_data Zizia::CsvTemplate.new.to_s, type: 'text/csv; charset=utf-8', disposition: 'attachment', filename: 'import_manifest.csv'
    end
  end
end
