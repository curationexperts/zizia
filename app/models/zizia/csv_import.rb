# frozen_string_literal: true

module Zizia
  class CsvImport < ::ApplicationRecord
    belongs_to :user

    # This is where the CSV file is stored:
    mount_uploader :manifest, CsvManifestUploader

    delegate :warnings, to: :manifest, prefix: true

    delegate :errors, to: :manifest, prefix: true

    delegate :records, to: :manifest, prefix: true

    def queue_start_job
      StartCsvImportJob.perform_later(id)
      # TODO: We'll probably need to store job_id on this record.
    end
  end
end
