# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Importing records from a CSV file' do
  context 'logged in as an admin user' do
    let(:admin_user) { FactoryBot.create(:admin) }
    before do
      login_as admin_user
    end

    it 'shows that there is no documentation if the markdown is absent' do
      visit '/importer_documentation/guide'
      expect(page).to have_content 'There is currently no documentation.'
    end
  end
end
