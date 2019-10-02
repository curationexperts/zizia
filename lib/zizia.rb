# frozen_string_literal: true

require "zizia/engine"

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

  require 'zizia/version'
  require 'zizia/metadata_mapper'
  require 'zizia/hash_mapper'
  require 'zizia/hyrax/hyrax_basic_metadata_mapper'
  require 'zizia/hyrax/based_near_attributes'
  require 'zizia/importer'
  require 'zizia/record_importer'
  require 'zizia/hyrax/hyrax_record_importer'
  require 'zizia/input_record'
  require 'zizia/validator'
  require 'zizia/validators/csv_format_validator'
  require 'zizia/validators/title_validator'
  require 'zizia/parser'
  require 'zizia/csv_template'

  ##
  # Module-wide options for `Zizia`.
  class Configuration
    attr_accessor :metadata_mapper_class

    def initialize
      self.metadata_mapper_class = Zizia::HyraxBasicMetadataMapper
    end
  end

  @configuration = Configuration.new

  require 'zizia/parsers/csv_parser'
  require 'zizia/hyrax/metadata_only_stack'
  require 'zizia/hyrax/hyrax_metadata_only_updater'
  require 'zizia/hyrax/hyrax_default_updater'
  require 'zizia/hyrax/hyrax_delete_files_updater'
end
