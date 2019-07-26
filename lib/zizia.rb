# frozen_string_literal: true

##
# Bulk object import for Samvera.
#
# == Importers
#
# {Importer} is the core class for importing records using {Zizia}.
# Importers accept a {Parser} and (optionally) a custom {RecordImporter}, and
# process each record in the given parser (see: {Parser#records}).
#
# @example Importing in bulk from a file
#   parser = Zizia::Parser.for(file: File.new('path/to/file.ext'))
#
#   Zizia::Importer.new(parser: parser).import if parser.validate
#
# @example A basic configuration
#   Zizia.config do |config|
#     # error/info streams must respond to `#<<`
#     config.default_error_stream = MyErrorStream.new
#     config.default_info_stream  = STDOUT
#   end
#
module Zizia
  ##
  # @yield the current configuration
  # @yieldparam config [Zizia::Configuration]
  #
  # @return [Zizia::Configuration] the current configuration
  def config
    yield @configuration if block_given?
    @configuration
  end
  module_function :config

  require 'zizia/log_stream'
  require 'zizia/version'
  require 'zizia/metadata_mapper'
  require 'zizia/hash_mapper'
  require 'zizia/hyrax_basic_metadata_mapper'
  require 'zizia/importer'
  require 'zizia/record_importer'
  require 'zizia/hyrax_record_importer'
  require 'zizia/input_record'
  require 'zizia/validator'
  require 'zizia/validators/csv_format_validator'
  require 'zizia/validators/title_validator'
  require 'zizia/parser'

  ##
  # Module-wide options for `Zizia`.
  class Configuration
    ##
    # @!attribute [rw] default_error_stream
    #   @return [#<<]
    # @!attribute [rw] default_info_stream
    #   @return [#<<]
    attr_accessor :default_error_stream
    attr_accessor :default_info_stream
    attr_accessor :metadata_mapper_class

    def initialize
      self.default_error_stream = Zizia::LogStream.new
      self.default_info_stream  = Zizia::LogStream.new
      self.metadata_mapper_class = Zizia::HyraxBasicMetadataMapper
    end
  end

  @configuration = Configuration.new

  require 'zizia/parsers/csv_parser'
  require 'zizia/metadata_only_stack'
end
