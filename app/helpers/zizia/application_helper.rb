# frozen_string_literal: true
module Zizia
  module ApplicationHelper
    def collections_for_select
      ActiveFedora::SolrService.query('has_model_ssim:Collection').map do |c|
        [c['title_tesim'][0], c['id']]
      end
    end

    def collections?
      !ActiveFedora::SolrService.query('has_model_ssim:Collection').empty?
    end
  end
end
