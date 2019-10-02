# frozen_string_literal: true

module Zizia
  class BasedNearAttributes
    attr_accessor :based_near

    def initialize(based_near)
      @based_near = based_near
    end

    ##
    # When submitting location data (a.k.a. the "based near" attribute) via the UI,
    # Hyrax expects to receive a `based_near_attributes` hash in a specific format.
    # We need to take geonames urls as provided by the customer and transform them to
    # mimic what the Hyrax UI would ordinarily produce. These will get turned into
    # Hyrax::ControlledVocabularies::Location objects upon ingest.
    # The expected hash looks like this:
    #   "based_near_attributes"=>
    #     {
    #       "0"=> {
    #               "id"=>"http://sws.geonames.org/5667009/", "_destroy"=>""
    #             },
    #       "1"=> {
    #               "id"=>"http://sws.geonames.org/6252001/", "_destroy"=>""
    #             },
    #   }
    # @return [Hash] a "based_near_attributes" hash as
    def to_h
      original_geonames_uris = based_near
      return if original_geonames_uris.empty?
      based_near_attributes = {}
      original_geonames_uris.each_with_index do |uri, i|
        based_near_attributes[i.to_s] = { 'id' => uri_to_sws(uri), "_destroy" => "" }
      end
      based_near_attributes
    end

    #
    # Take a user-facing geonames URI and return an sws URI, of the form Hyrax expects
    # (e.g., "http://sws.geonames.org/6252001/")
    # @param [String] uri
    # @return [String] an sws style geonames uri
    def uri_to_sws(uri)
      uri = URI(uri)
      geonames_number = uri.path.split('/')[1]
      "http://sws.geonames.org/#{geonames_number}/"
    end
  end
end
