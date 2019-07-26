# frozen_string_literal: true
require 'spec_helper'

RSpec.describe "importer_documentation/guide.html.erb", type: :view do
  it 'renders as html' do
    render
    expect(rendered).to match(/<h1 id="title">Title<\/h1>/)
  end
end
