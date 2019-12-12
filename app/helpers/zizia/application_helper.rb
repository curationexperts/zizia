# frozen_string_literal: true
module Zizia
  module ApplicationHelper
    def human_update_actor_stack(update_actor_stack)
      case update_actor_stack
      when 'HyraxDelete'
        'Overwrite All Files & Metadata'
      when 'HyraxMetadataOnly'
        'Update Existing Metadata, create new works'
      when 'HyraxOnlyNew'
        'Ignore Existing Works, new works only'
      else
        'Unknown'
      end
    end

    def sortable(column, title = nil)
      title ||= column.titleize
      css_class = column == sort_column ? "current #{sort_direction}" : nil
      direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
      link_to title, { sort: column, direction: direction }, class: css_class
    end

    def collections_for_select
      ActiveFedora::SolrService.query('has_model_ssim:Collection').map do |c|
        [c['title_tesim'][0], c['id']]
      end
    end

    def collections?
      !ActiveFedora::SolrService.query('has_model_ssim:Collection').empty?
    end

    def status_icon(status)
      # rubocop:disable Rails/OutputSafety
      return "<span class='glyphicon glyphicon-ok-sign text-success' aria-label='Status: Complete'></span>".html_safe if status == 'attached'
      "<span class='glyphicon glyphicon-question-sign' aria-label='Status: Unknown'></span>".html_safe
    end
  end
end
