# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'viewing the Hyrax home page' do
  it 'has a Hyrax homepage' do
    visit '/'
    expect(page).to have_content 'Hyrax'
  end
end
