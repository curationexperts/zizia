# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "zizia/metadata_details/show.html.erb", type: :view do
  before do
    assign(:details, [{
             attribute: 'title',
             label: 'Title',
             csv_header: 'title',
             predicate: 'n/a',
             multiple: 'true',
             type: 'String',
             validator: 'n/a',
             required_on_form: 'true',
             usage: 'none'
           }])
    assign(:delimiter, '|')
    allow(view).to receive(:importer_documentation_csv_path).and_return('./csv')
  end

  it 'renders as html' do
    render
    expect(rendered).to match(/<h3 class="field-label">\s*Title\s*<\/h3>/)
  end

  it 'provides a link to the import template' do
    render
    expect(rendered).to have_link("import_template", href: './csv')
  end
end
