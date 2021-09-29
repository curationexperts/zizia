# frozen_string_literal: true

# Validate a CSV file.
#
# Don't put expensive validations in this class.
# This is meant to be used for running a few quick
# validations before starting a CSV-based import.
# It will be called during the HTTP request/response,
# so long-running validations will make the page load
# slowly for the user.  Any validations that are slow
# should be run in background jobs during the import
# instead of here.
module Zizia
  class CsvManifestValidator
    # @param manifest_uploader [CsvManifestUploader] The manifest that's mounted to a CsvImport record.  See carrierwave gem documentation.  This is basically a wrapper for the CSV file.
    def initialize(manifest_uploader)
      @csv_file = manifest_uploader.file
      @errors = []
      @warnings = []
    end

    # Errors and warnings for the CSV file.
    attr_reader :errors, :warnings
    attr_reader :csv_file

    def validate
      parse_csv
      return unless @rows

      missing_headers
      duplicate_headers
      unrecognized_headers
      missing_values
      invalid_license
      invalid_resource_type
      invalid_rights_statement
      invalid_object_type
    end

    # One record per row
    def record_count
      return nil unless @rows
      @rows.size - 1 # Don't include the header row
    end

    def delimiter
      @delimiter ||= default_delimiter
    end
    attr_writer :delimiter

    def default_delimiter
      Zizia::HyraxBasicMetadataMapper.new.delimiter
    end

    def valid_headers
      Zizia::HyraxBasicMetadataMapper.new.headers.map(&:to_s)
    end

    def parse_csv
      @rows = CSV.read(csv_file.path).reject { |x| x.empty? || x.all?(nil) }
      @headers = @rows.first || []
      @transformed_headers = @headers.map { |header| header.downcase.strip }
    rescue
      @errors << 'We are unable to read this CSV file.'
    end

    def object_types
      return ["work"] unless @transformed_headers.include?("object type")
      original_object_types = @rows.map { |row| row[@transformed_headers.find_index("object type")] }
      original_object_types.map { |object_type| map_object_type(object_type) }.compact.uniq
    end

    def map_object_type(orig_value)
      case orig_value&.downcase
      when "c", "collection"
        "collection"
      when "w", "work"
        "work"
      when "f", "file"
        "file"
      # Don't return an object type for the header
      when "object type"
        nil
      else
        "work"
      end
    end

    def missing_headers
      required_headers_for_sheet.each do |header|
        next if @transformed_headers.include?(header)
        @errors << "Missing required column: \"#{header.titleize}\".  Your spreadsheet must have this column."
      end
    end

    def required_headers_for_sheet
      object_types.flat_map { |object_type| required_headers(object_type) }.compact.uniq
    end

    def required_headers(object_type = "w")
      return work_headers if object_type.nil?
      if object_type.casecmp("c").zero? || object_type.casecmp("collection").zero?
        ['title', 'visibility']
      elsif object_type.casecmp("f").zero? || object_type.casecmp("file").zero?
        ['files', 'parent']
      else
        work_headers
      end
    end

    # TODO: Map these headers appropriately all the way through the ingest
    # Right now the transformed headers only downcase and strip them, they don't translate them
    # based on the associated mapper
    def work_headers
      ['title', 'creator', 'keyword', 'rights statement', 'visibility', 'files', 'deduplication_key']
    end

    def duplicate_headers
      duplicates = []
      sorted_headers = @transformed_headers.sort
      sorted_headers.each_with_index do |x, i|
        duplicates << x if x == sorted_headers[i + 1]
      end
      duplicates.uniq.each do |header|
        @errors << "Duplicate column names: You can have only one \"#{header.titleize}\" column."
      end
    end

    # Warn the user if we find any unexpected headers.
    def unrecognized_headers
      extra_headers = @transformed_headers - valid_headers
      extra_headers.each do |header|
        @warnings << "The field name \"#{header}\" is not supported.  This field will be ignored, and the metadata for this field will not be imported."
      end
    end

    def missing_values
      @rows.each_with_index do |row, i|
        next if i.zero? # Skip the header row
        required_column_numbers(row).each_with_index do |required_column_number, j|
          next unless row[required_column_number].blank?
          @errors << "Missing required metadata in row #{i + 1}: \"#{required_headers(object_type(row))[j].titleize}\" field cannot be blank"
        end
      end
    end

    def required_column_numbers(row)
      if @transformed_headers.include?("object type")
        required_headers(object_type(row)).map { |header| @transformed_headers.find_index(header) }.compact
      else
        required_headers.map { |header| @transformed_headers.find_index(header) }.compact
      end
    end

    private

      def object_type(row)
        row[@transformed_headers.find_index("object type")]&.downcase
      end

      # Only allow valid license values expected by Hyrax.
      # Otherwise the app throws an error when it displays the work.
      def invalid_license
        validate_values('license', :valid_licenses)
      end

      def invalid_resource_type
        validate_values('resource type', :valid_resource_types)
      end

      def invalid_rights_statement
        validate_values('rights statement', :valid_rights_statements)
      end

      def invalid_object_type
        validate_values('object type', :valid_object_types, true)
      end

      def valid_licenses
        @valid_license_ids ||= Hyrax::LicenseService.new.authority.all.select { |license| license[:active] }.map { |license| license[:id] }
      end

      def valid_resource_types
        @valid_resource_type_ids ||= Qa::Authorities::Local.subauthority_for('resource_types').all.select { |term| term[:active] }.map { |term| term[:id] }
      end

      def valid_rights_statements
        @valid_rights_statement_ids ||= Qa::Authorities::Local.subauthority_for('rights_statements').all.select { |term| term[:active] }.map { |term| term[:id] }
      end

      def valid_object_types
        @valid_object_types ||= ['c', 'collection', 'w', 'work', 'f', 'file']
      end

      # Make sure this column contains only valid values
      def validate_values(header_name, valid_values_method, case_insensitive = false)
        column_number = @transformed_headers.find_index(header_name)
        return unless column_number

        @rows.each_with_index do |row, i|
          next if i.zero? # Skip the header row
          next unless row[column_number]
          values = row[column_number].split(delimiter)
          valid_values = method(valid_values_method).call
          invalid_values = invalid_values(values, valid_values, case_insensitive)

          invalid_values.each do |value|
            @errors << "Invalid #{header_name.titleize} in row #{i + 1}: #{value}"
          end
        end
      end

      def invalid_values(values, valid_values, case_insensitive = false)
        if case_insensitive
          values.select do |value|
            valid_values = valid_values.map(&:downcase)
            !valid_values.include?(value.downcase)
          end
        else
          values.select do |value|
            !valid_values.include?(value)
          end
        end
      end
  end
end
