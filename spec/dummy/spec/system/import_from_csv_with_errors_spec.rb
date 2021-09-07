# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Importing records from a CSV file with fatal errors', :clean, type: :system, js: true do
  let(:bad_csv_file) { File.join(fixture_path, 'csv_import', 'csv_files_with_problems', 'missing_headers.csv') }

  let(:collection) { FactoryBot.build(:collection) }
  let(:test_strategy) { Flipflop::FeatureSet.current.test! }

  context 'logged in as an admin user' do
    let(:admin_user) { FactoryBot.create(:admin) }
    before do
      login_as admin_user
    end

    context "with the old ui" do

      before do
        test_strategy.switch!(:new_zizia_ui, false)
        collection.save!
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

    context "with the new ui" do
      before do
        test_strategy.switch!(:new_zizia_ui, true)
      end

      it 'aborts the import' do
        visit '/csv_imports/new'
        # Fill in and submit the form
        attach_file('csv_import[manifest]', bad_csv_file, make_visible: true)
        click_on 'Preview Import'

        # We expect to see errors for this CSV file.
        expect(page).to have_content 'Missing required column: "Title".'

        # Because there are fatal errors, the 'Start Import' button should not be available.
        expect(page).not_to have_button('Start Import')
        expect(page).to have_content 'You will need to correct the errors'

        # There is a link so the user can start over with a new CSV file.
        click_on 'Try Again'
      end
      context "with a csv with an unrecognized object_type" do
        let(:csv_file) { File.join(fixture_path, 'csv_import', 'csv_files_with_problems', 'wrong_object_type.csv') }

        it 'aborts the import' do
          visit '/csv_imports/new'
          # Fill in and submit the form
          attach_file('csv_import[manifest]', csv_file, make_visible: true)
          click_on 'Preview Import'

          # We expect to see errors for this CSV file.
          expect(page).to have_content 'Invalid Object Type in row 2: i'

          # Because there are fatal errors, the 'Start Import' button should not be available.
          expect(page).not_to have_button('Start Import')
          expect(page).to have_content 'You will need to correct the errors'

          # There is a link so the user can start over with a new CSV file.
          click_on 'Try Again'
        end
      end
    end
  end
end
