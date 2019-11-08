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

    # Returns thumbnail urls based on the work's deduplication_key
    # @return [Array<String>] the work's thumbnail urls
    def thumbnails
      thumbnail_urls = []
      return thumbnail_urls if deduplication_key.nil?
      file_sets = ActiveFedora::SolrService.get("deduplication_key_tesim:#{deduplication_key}")
                                           .dig('response', 'docs', 0, 'file_set_ids_ssim')
      return thumbnail_urls unless file_sets
      file_sets.each do |file_set_id|
        thumbnail_urls.push(ActiveFedora::SolrService.get("id:#{file_set_id}")
                              .dig('response', 'docs', 0, 'thumbnail_path_ss'))
      end
      thumbnail_urls
    end
  end
end
