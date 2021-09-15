# frozen_string_literal: true
require 'spec_helper'
require 'rails_helper'

RSpec.describe "zizia/importer_documentation/guide.html.erb", type: :view do
  before do
    allow(view).to receive(:render_guide).and_return('<h1 id="title">Title</h1>')
  end

  it 'renders as html' do
    render
    expect(rendered).to match(/<h1 id="title">Title<\/h1>/)
  end
end
