# frozen_string_literal: true
module Zizia
  module MetadataDetailsHelper
    def css_class(value)
      return 'missing' if value == 'not configured'
      return 'missing' if value.match?(/translation missing/)
    end

    def system_field(detail)
      return "" if detail.nil?
      return "non-system-field" unless detail[:usage]
      return "system-field" if detail[:usage].match?("system field")
      "non-system-field"
    end

    def hide_system_field(detail)
      return "" if detail.nil?
      return "" unless detail[:usage]
      # rubocop: disable Rails/OutputSafety
      return "style='display: none'".html_safe if detail[:usage].match?("system field")
      # rubocop: enable Rails/OutputSafety
      ""
    end
  end
end
