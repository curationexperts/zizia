# frozen_string_literal: true

module ImporterDocumentationHelper
  def render_guide
    renderer = Redcarpet::Render::HTML.new(autolink: true, with_toc_data: true)
    markdown = Redcarpet::Markdown.new(renderer)
    if File.exist?(Rails.root.join('app', 'assets', 'markdown', 'importer_guide.md'))
      markdown.render(File.open(Rails.root.join('app', 'assets', 'markdown', 'importer_guide.md')).read)
    else
      'There is currently no documentation.'
    end
  end
end
