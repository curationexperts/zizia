# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Importing records from a CSV file', type: :system, js: true do
  let(:csv_file) { File.join(fixture_path, 'csv_import', 'csv_files_with_problems', 'extra - headers.csv') }

  context 'logged in as an admin user' do
    let(:admin_user) { FactoryBot.create(:admin) }
    let(:test_strategy) { Flipflop::FeatureSet.current.test! }

    before do
      login_as admin_user
    end

    context 'using the new UI' do
      before do
        test_strategy.switch!(:new_zizia_ui, true)
        Collection.destroy_all
      end

      it 'starts the import' do
        visit '/csv_imports/new'
        expect(page).not_to have_content 'Testing Collection'
        expect(page).not_to have_content '["Testing Collection"]'

        # Fill in and submit the form
        attach_file('csv_import[manifest]', csv_file, make_visible: true)
        click_on 'Preview Import'

        # We expect to see warnings for this CSV file.
        expect(page).to have_content 'The field name "another_header_2" is not supported'

        expect(page).to have_content 'This import will process 3 row(s).'

        # There is a link so the user can cancel.
        expect(page).to have_link 'Cancel', href: '/csv_imports/new?locale=en'

        # After reading the warnings, the user decides
        # to continue with the import.
        click_on 'Start Import'

        # The show page for the CsvImport
        expect(page).to have_content 'extra_-_headers.csv'
        expect(page).to have_content 'Start time'
      end

    end

    context 'using the old UI' do
      let(:collection) { FactoryBot.build(:collection, title: ['Testing Collection']) }

      before do
        test_strategy.switch!(:new_zizia_ui, false)
        Collection.destroy_all
        collection.save!
      end

      it 'starts the import' do
        visit '/csv_imports/new'
        expect(page).to have_content 'Testing Collection'
        expect(page).not_to have_content '["Testing Collection"]'
        select 'Testing Collection', from: "csv_import[fedora_collection_id]"

        # Fill in and submit the form
        attach_file('csv_import[manifest]', csv_file, make_visible: true)
        click_on 'Preview Import'

        # We expect to see warnings for this CSV file.
        expect(page).to have_content 'The field name "another_header_2" is not supported'

        # We expect to see the title of the collection on the page
        expect(page).to have_content 'Testing Collection'

        expect(page).to have_content 'This import will process 3 row(s).'

        # There is a link so the user can cancel.
        expect(page).to have_link 'Cancel', href: '/csv_imports/new?locale=en'

        # After reading the warnings, the user decides
        # to continue with the import.
        click_on 'Start Import'

        # The show page for the CsvImport
        expect(page).to have_content 'extra_-_headers.csv'
        expect(page).to have_content 'Start time'

        # We expect to see the title of the collection on the page
        expect(page).to have_content 'Testing Collection'
      end
    end

  end
end
