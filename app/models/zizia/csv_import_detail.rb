# frozen_string_literal: true
module Zizia
  class CsvImportDetail < ::ApplicationRecord
    after_initialize :set_defaults, unless: :persisted?

    belongs_to :csv_import
    has_many :pre_ingest_works
    has_many :pre_ingest_files, through: :pre_ingest_works

    def total_size
      return 0 if pre_ingest_files.empty?
      pre_ingest_files.map(&:size).sum
    end

    def set_defaults
      self.success_count = 0
      self.failure_count = 0
    end
  end
end
