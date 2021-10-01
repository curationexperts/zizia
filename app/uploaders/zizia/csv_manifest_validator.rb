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
      return unless @parsed_csv

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
      return nil unless @parsed_csv.size
      rows_with_values = @parsed_csv.reject { |row| row.to_hash.values.all?(&:nil?) }
      rows_with_values.count
    end

    def delimiter
      @delimiter ||= Zizia::HyraxBasicMetadataMapper.new.delimiter
    end
    attr_writer :delimiter

    def valid_headers
      @valid_headers ||= begin
        Zizia::HyraxBasicMetadataMapper.new.headers.map do |header|
          if header.class == Symbol
            header
          else
            header.parameterize.underscore.to_sym
          end
        end
      end
    end

    def parse_csv
      # Note: The 'table' method automatically turns the headers into symbols with underscores
      @parsed_csv = CSV.table(csv_file.path)
    rescue
      @errors << 'We are unable to read this CSV file.'
    end

    def headers
      @headers ||= @parsed_csv.headers
    end

    def object_types
      @object_types ||= begin
        return ["work"] unless headers.include?(:object_type)
        @parsed_csv[:object_type].map { |object_type| map_object_type(object_type) }.compact.uniq
      end
    end

    def map_object_type(orig_value)
      case orig_value&.downcase
      when "c", "collection"
        "collection"
      when "w", "work"
        "work"
      when "f", "file"
        "file"
      else
        "work"
      end
    end

    def missing_headers
      required_headers_for_sheet.each do |header|
        next if headers.include?(header)
        @errors << "Missing required column: \"#{header.to_s.titleize}\".  Your spreadsheet must have this column."
      end
    end

    def required_headers_for_sheet
      object_types.flat_map { |object_type| required_headers(object_type) }.compact.uniq
    end

    def required_headers(object_type = "w", *row)
      return default_work_headers if object_type.nil?
      case map_object_type(object_type)
      when 'collection'
        [:title, :visibility]
      when 'file'
        [:files, :parent]
      when 'work'
        return default_work_headers if row.empty?
        required_work_headers(row)
      else
        default_work_headers
      end
    end

    def required_work_headers(row)
      file_rows = @parsed_csv.select { |csv_row| map_object_type(csv_row[:object_type]) == 'file' }
      parent_identifiers_for_file_rows = file_rows.map { |csv_row| csv_row[:parent] }
      return default_work_headers unless parent_identifiers_for_file_rows.include?(row.first[:identifier])
      default_work_headers - [:files]
    end

    # TODO: Map these headers appropriately all the way through the ingest
    # Right now we just turn them into symbols, we don't translate them
    # based on the associated mapper
    def default_work_headers
      [:title, :creator, :keyword, :rights_statement, :visibility, :files, :deduplication_key]
    end

    def duplicate_headers
      duplicates = headers.group_by { |e| e }.select { |_k, v| v.size > 1 }.map(&:first)
      duplicates.uniq.each do |header|
        @errors << "Duplicate column names: You can have only one \"#{header.to_s.titleize}\" column."
      end
    end

    # Warn the user if we find any unexpected headers.
    def unrecognized_headers
      extra_headers = headers - valid_headers
      extra_headers.each do |header|
        @warnings << "The field name \"#{header}\" is not supported.  This field will be ignored, and the metadata for this field will not be imported."
      end
    end

    def missing_values
      @parsed_csv.each_with_index do |row, index|
        # Skip blank rows
        next if row.to_hash.values.all?(&:nil?)
        required_headers(row[:object_type], row).each do |required_header|
          next unless row[required_header].blank?
          @errors << "Missing required metadata in row #{index + 2}: \"#{required_header.to_s.titleize}\" field cannot be blank"
        end
      end
    end

    private

      # Only allow valid license values expected by Hyrax.
      # Otherwise the app throws an error when it displays the work.
      def invalid_license
        validate_values(:license, :valid_licenses)
      end

      def invalid_resource_type
        validate_values(:resource_type, :valid_resource_types)
      end

      def invalid_rights_statement
        validate_values(:rights_statement, :valid_rights_statements)
      end

      def invalid_object_type
        validate_values(:object_type, :valid_object_types, true)
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
        @parsed_csv.each_with_index do |row, index|
          next if row.to_hash.values.all?(&:nil?) # Skip blank rows
          next unless row[header_name]
          values = row[header_name].split(delimiter)
          valid_values = method(valid_values_method).call
          invalid_values = invalid_values(values, valid_values, case_insensitive)

          invalid_values.each do |value|
            @errors << "Invalid #{header_name.to_s.titleize} in row #{index + 2}: #{value}"
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
