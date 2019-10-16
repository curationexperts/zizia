# frozen_string_literal: true
require 'uri'

module Zizia
  ##
  # A mapper for Hyrax metadata.
  #
  # Maps from hash accessor syntax (`['title']`) to method call dot syntax (`.title`).
  #
  # The fields provided by this mapper are the same as the properties defined in `Hyrax::CoreMetadata` and `Hyrax::BasicMetadata`.
  #
  # @note This mapper allows you to set values for all the Hyrax fields, but depending on how you create the records, some of the values might get clobbered.  For example, if you use Hyrax's actor stack to create records, it might overwrite fields like `date_modified` or `depositor`.
  #
  # @see HashMapper Parent class for more info and examples.
  class HyraxBasicMetadataMapper < HashMapper
    # If your CSV headers don't exactly match the
    # the method name for the property's setter
    # method, add a mapping here.
    # Example: the method name is work.resource_type,
    # but in the CSV file, the header is
    # 'resource type' (without the underscore).
    CSV_HEADERS = {
      resource_type: 'resource type',
      description: 'abstract or summary',
      rights_statement: 'rights statement',
      date_created: 'date created',
      based_near: 'location',
      related_url: 'related url'
    }.freeze

    ##
    # @return [Enumerable<Symbol>] The fields the mapper can process.
    def fields
      core_fields + basic_fields + [:visibility, :files]
    end

    # Properties defined with `multiple: false` in
    # Hyrax should return a single value instead of
    # an Array of values.
    def depositor
      single_value('depositor')
    end

    def date_modified
      single_value('date_modified')
    end

    def label
      single_value('label')
    end

    def relative_path
      single_value('relative_path')
    end

    def import_url
      single_value('import_url')
    end

    # We should accept visibility values that match the UI and transform them into
    # the controlled vocabulary term expected by Hyrax
    def visibility
      case metadata[matching_header('visibility')]&.downcase&.gsub(/\s+/, "")
      when 'public'
        'open'
      when 'open'
        'open'
      when 'registered'
        'authenticated'
      when "authenticated"
        'authenticated'
      when ::Hyrax::Institution.name&.downcase&.gsub(/\s+/, "")
        'authenticated'
      when ::Hyrax::Institution.name_full&.downcase&.gsub(/\s+/, "")
        'authenticated'
      when 'private'
        'restricted'
      when 'restricted'
        'restricted'
      else
        'restricted' # This is the default if nothing else matches
      end
    end

    def files
      map_field('files')
    end

    ##
    # @return [String] The delimiter that will be used to split a metadata field into separate values.
    # @example
    #   mapper = HyraxBasicMetadataMapper.new
    #   mapper.metadata = { 'language' => 'English|~|French|~|Japanese' }
    #   mapper.language = ['English', 'French', 'Japanese']
    #
    def delimiter
      @delimiter ||= '|~|'
    end
    attr_writer :delimiter

    ##
    # @see MetadataMapper#map_field
    def map_field(name)
      method_name = name.to_s
      method_name = CSV_HEADERS[name] if CSV_HEADERS.keys.include?(name)
      key = matching_header(method_name)
      Array(metadata[key]&.split(delimiter))
    end

    def self.csv_header(field)
      CSV_HEADERS[field.to_sym]
    end

    protected

      # Some fields should have single values instead
      # of array values.
      def single_value(field_name)
        metadata[matching_header(field_name)]
      end

      # Lenient matching for headers.
      # If the user has headers like:
      #   'Title' or 'TITLE' or 'Title  '
      # it should match the :title field.
      def matching_header(field_name)
        metadata.keys.find do |key|
          next unless key
          key.downcase.strip == field_name
        end
      end

      # Properties defined in Hyrax::CoreMetadata
      # Note that depositor, date_uploaded and date_modified are NOT set here,
      # even though they are defined in Hyrax::CoreMetadata.
      # Hyrax expects to set these fields itself, and
      # sending a metadata value for these fields interferes with
      # Hyrax expected behavior.
      def core_fields
        [:title]
      end

      # Properties defined in Hyrax::BasicMetadata
      # System related fields like :relative_path, and :import_url
      # are not included here because we don't expect users to directly
      # import them.
      def basic_fields
        [:resource_type, :creator, :contributor,
         :description, :keyword, :license,
         :rights_statement, :publisher, :date_created,
         :subject, :language, :identifier,
         :based_near, :related_url,
         :bibliographic_citation, :source]
      end
  end
end
