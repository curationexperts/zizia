# frozen_string_literal: true
module Zizia
  class PreIngestWork < ::ApplicationRecord
    has_many :pre_ingest_files

    # Returns the title based on the deduplication_key if the work has been indexed to solr
    # @return [String] the work's title
    def title
      return 'This work does not have a deduplication key.' if deduplication_key.nil?
      solr_title = ActiveFedora::SolrService.get("deduplication_key_tesim:#{deduplication_key}")
                                            .dig('response', 'docs', 0, 'title_tesim', 0)
      return solr_title unless solr_title.nil?
      'This work\'s metadata has not been indexed yet.'
    end

    def collection
      @collection ||= Collection.find(collection_id) if collection_id
    end

    def collection_title
      collection.title.first if collection_id
    rescue Ldp::Gone
      "The associated collection has been deleted."
    end

    def collection_identifier
      collection.identifier.first if collection_id
    rescue Ldp::Gone
      "deleted"
    end
  end
end
