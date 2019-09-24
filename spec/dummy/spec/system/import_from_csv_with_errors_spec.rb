# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Importing records from a CSV file with fatal errors', type: :system, js: true do
  let(:bad_csv_file) { File.join(fixture_path, 'csv_import', 'csv_files_with_problems', 'missing_headers.csv') }

  let(:collection) { FactoryBot.build(:collection) }

  context 'logged in as an admin user' do
    let(:admin_user) { FactoryBot.create(:admin) }
    before do
      collection.save!
      login_as admin_user
    end

    it 'aborts the import' do
      visit '/csv_imports/new'
      # Fill in and submit the form
      attach_file('csv_import[manifest]', bad_csv_file, make_visible: true)
      select collection.title.first, from: "csv_import[fedora_collection_id]"
      click_on 'Preview Import'

      # We expect to see errors for this CSV file.
      expect(page).to have_content 'Missing required column: "Title".'

      # Because there are fatal errors, the 'Start Import' button should not be available.
      expect(page).not_to have_button('Start Import')
      expect(page).to have_content 'You will need to correct the errors'

      # There is a link so the user can start over with a new CSV file.
      click_on 'Try Again'
    end
  end
end
