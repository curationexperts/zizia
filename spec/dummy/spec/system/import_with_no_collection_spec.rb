# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Trying to import a CSV without collections', :clean, type: :system, js: true do
  context 'logged in as an admin user' do
    let(:admin_user) { FactoryBot.create(:admin) }

    before do
      login_as admin_user
    end

    it 'displays a warning message' do
      visit '/csv_imports/new'
      expect(page.html.match?(/no-collection/)).to eq(true)
    end
  end
end
