# frozen_string_literal: true

module Zizia
  class PreIngestFile < ::ApplicationRecord
    belongs_to :pre_ingest_work

    attr_reader :checksum, :ingest_status

    def basename
      File.basename(filename)
    end

    def indexed?
      return false unless File.exist?(filename)
      status = ActiveFedora::SolrService.get("digest_ssim:urn\\:sha1\\:#{sha1}")
                                        .dig('response', 'docs', 0, 'digest_ssim', 0)
      return true unless status.nil?
      false
    end

    def sha1
      @checksum ||= File.open(filename, 'rb') { |file| Digest::SHA1.hexdigest(file.read) }
    end
  end
end
