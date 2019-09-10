# frozen_string_literal: true

require 'carrierwave'

module Zizia
  class CsvManifestUploader < CarrierWave::Uploader::Base
    # Choose what kind of storage to use for this uploader:
    storage :file

    # Process calls that method whenever a file is uploaded.
    process :validate_csv

    # The directory where the csv manifest will be stored.
    def store_dir
      manifests_path || Rails.root.join('tmp', 'csv_uploads')
    end

    def cache_dir
      manifests_cache_path || Rails.root.join('tmp', 'csv_uploads_cache')
    end

    # Add a white list of extensions which are allowed to be uploaded.
    # For images you might use something like this:
    #   %w(jpg jpeg gif png)
    def extension_whitelist
      %w[csv]
    end

    # These are stored in memory only, not persisted
    def errors
      @validator ? @validator.errors : []
    end

    # These are stored in memory only, not persisted
    def warnings
      @validator ? @validator.warnings : []
    end

    def records
      @validator ? @validator.record_count : 0
    end

    private

      def manifests_path
        return false if ENV['CSV_MANIFESTS_PATH'].nil?
        return false unless File.directory?(ENV['CSV_MANIFESTS_PATH'])
        ENV['CSV_MANIFESTS_PATH']
      end

      def manifests_cache_path
        return false if ENV['CSV_MANIFESTS_CACHE_PATH'].nil?
        return false unless File.directory?(ENV['CSV_MANIFESTS_CACHE_PATH'])
        ENV['CSV_MANIFESTS_CACHE_PATH']
      end

      def validate_csv
        @validator = CsvManifestValidator.new(self)
        @validator.validate
      end
  end
end
