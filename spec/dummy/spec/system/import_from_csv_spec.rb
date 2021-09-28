# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Importing records from a CSV file', :perform_jobs, clean: true, type: :system, js: true do
  before do
    allow(CharacterizeJob).to receive(:perform_later)
    ENV['IMPORT_PATH'] = File.join(fixture_path, 'images')
  end

  let(:csv_file) { File.join(fixture_path, 'csv_import', 'good', 'all_fields.csv') }
  let(:csv_metadata_update_file) { File.join(fixture_path, 'csv_import', 'good', 'all_fields_metadata_update.csv') }
  let(:csv_complete_update_file) { File.join(fixture_path, 'csv_import', 'good', 'all_fields_complete_update.csv') }
  let(:csv_only_new_file) { File.join(fixture_path, 'csv_import', 'good', 'all_fields_only_new.csv') }
  let(:test_strategy) { Flipflop::FeatureSet.current.test! }

  context 'logged in as an admin user' do
    let(:admin_user) { FactoryBot.create(:admin) }

    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let(:default_collection_type) { Hyrax::CollectionType.find_or_create_default_collection_type }
    let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    before do
      # Create the default collection type in order to create a new collection
      default_collection_type
      # Create a single action that can be taken
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

      # Grant the user access to deposit into the admin set.
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'user',
        agent_id: admin_user.user_key,
        access: 'deposit'
      )

      login_as admin_user
    end

    context 'using the new UI' do
      before do
        test_strategy.switch!(:new_zizia_ui, true)
      end

      it 'creates a collection and a work via the UI' do
        visit '/csv_imports/new'
        # Fill in and submit the form
        expect do
          select 'Update Existing Metadata, create new works', from: "csv_import[update_actor_stack]"
          attach_file('csv_import[manifest]', csv_file, make_visible: true)

          expect(page).to have_content('You sucessfully uploaded this CSV: all_fields.csv')

          click_on 'Preview Import'

          expect(page).to have_content 'This import will process 2 row(s).'

          # There is a link so the user can cancel.
          expect(page).to have_link 'Cancel', href: '/csv_imports/new?locale=en'

          expect(page).not_to have_content('The field name "parent" is not supported.')
          expect(page).not_to have_content('The field name "object type" is not supported.')

          # After reading the warnings, the user decides
          # to continue with the import.
          click_on 'Start Import'
        end.to change { Work.count }.by(1)
            .and change { Collection.count }.by(1)

        # The show page for the CsvImport
        expect(page).to have_content 'all_fields.csv'
        expect(page).to have_content 'Start time'

        # Ensure that all the fields got assigned as expected
        work_one = Work.where(title: "*haberdashery*").first
        expect(work_one.title.first).to match(/haberdashery/)
      end

      context 'with a variety of object types' do
        let(:csv_file) { File.join(fixture_path, 'csv_import', 'good', 'mix_of_object_types.csv') }

        it 'creates the different types of objects' do
          # Let the background jobs run, and check that the expected number of records got created.
          expect do
            visit '/csv_imports/new'
            select 'Update Existing Metadata, create new works', from: "csv_import[update_actor_stack]"

            attach_file('csv_import[manifest]', csv_file, make_visible: true)
            click_on 'Preview Import'
            click_on 'Start Import'
          end.to change { Work.count }.by(3)
             .and change { Collection.count }.by(3)
        end
      end

      context 'with an existing collection' do
        let(:collection) { FactoryBot.build(:collection, title: ['Collection of Zuccini'], identifier: ['def/123']) }
        before do
          collection.save!
        end

        it 'adds the work to the parent collection' do
          # Let the background jobs run, and check that the expected number of records got created.
          expect do
            visit '/csv_imports/new'
            select 'Update Existing Metadata, create new works', from: "csv_import[update_actor_stack]"

            attach_file('csv_import[manifest]', csv_file, make_visible: true)
            click_on 'Preview Import'
            click_on 'Start Import'
          end.to change { Work.count }.by(1)

          # Ensure that all the fields got assigned as expected
          work = Work.where(title: "*haberdashery*").first
          expect(collection.identifier&.first).to eq 'def/123'
          expect(work.member_of_collection_ids).to eq [collection.id]

          visit "csv_import_details/show/#{Zizia::CsvImportDetail.last.id}"
          within('#works-table') do
            expect(page).to have_content('Files')
            expect(page).to have_content('Collection of Zuccini')
            expect(page).to have_content('Collection Identifier')
            expect(page).to have_content('def/123')
          end
        end
      end
    end
    context 'using the old UI' do
      let(:collection) { FactoryBot.build(:collection, title: ['Testing Collection']) }

      before do
        test_strategy.switch!(:new_zizia_ui, false)

        collection.save!
      end

      it 'starts the import' do
        # Let the background jobs run, and check that the expected number of records got created.
        expect do
          visit '/csv_imports/new'
          expect(page).to have_content 'Testing Collection'
          expect(page).not_to have_content '["Testing Collection"]'

          # Fill in and submit the form
          select 'Testing Collection', from: "csv_import[fedora_collection_id]"
          select 'Update Existing Metadata, create new works', from: "csv_import[update_actor_stack]"
          attach_file('csv_import[manifest]', csv_file, make_visible: true)

          expect(page).to have_content('You sucessfully uploaded this CSV: all_fields.csv')

          click_on 'Preview Import'

          # We expect to see the title of the collection on the page
          expect(page).to have_content 'Testing Collection'

          expect(page).to have_content 'This import will process 2 row(s).'

          # There is a link so the user can cancel.
          expect(page).to have_link 'Cancel', href: '/csv_imports/new?locale=en'

          # After reading the warnings, the user decides
          # to continue with the import.
          click_on 'Start Import'

          # The show page for the CsvImport
          expect(page).to have_content 'all_fields.csv'
          expect(page).to have_content 'Start time'

          # We expect to see the title of the collection on the page
          expect(page).to have_content 'Testing Collection'
        end.to change { Work.count }.by(1)

        # Ensure that all the fields got assigned as expected
        work_one = Work.where(title: "*haberdashery*").first
        expect(work_one.title.first).to match(/haberdashery/)

        # Ensure location (a.k.a. based_near) gets turned into a controlled vocabulary term
        expect(work_one.based_near.first.class).to eq Hyrax::ControlledVocabularies::Location

        # It sets the date_uploaded field
        expect(work_one.date_uploaded.class).to eq DateTime

        # Ensure visibility gets turned into expected Hyrax values (e.g., 'PUBlic' becomes 'open')
        expect(work_one.visibility).to eq 'open'

        # Ensure work is being added to the collection as expected
        expect(work_one.member_of_collection_ids).to eq [collection.id]

        visit "/concern/works/#{work_one.id}"
        expect(page).to have_content work_one.title.first
        # Controlled vocabulary location should have been resolved to its label name
        expect(page).to have_content "Los Angeles"

        # The license value resolves to a controlled field from creative commons
        expect(page).to have_link "Attribution 4.0"


        # Updating
        # Let the background jobs run, and check that a new work was not created, but that the existing work
        # was updated
        expect do
          visit '/csv_imports/new'
          expect(page).to have_content 'Testing Collection'
          expect(page).not_to have_content '["Testing Collection"]'
          select 'Testing Collection', from: "csv_import[fedora_collection_id]"
          select 'Update Existing Metadata, create new works', from: "csv_import[update_actor_stack]"

          # Fill in and submit the form
          attach_file('csv_import[manifest]', csv_metadata_update_file, make_visible: true)

          click_on 'Preview Import'

          # We expect to see the title of the collection on the page
          expect(page).to have_content 'Testing Collection'

          expect(page).to have_content 'This import will process 1 row(s).'
          # There is a link so the user can cancel.
          expect(page).to have_link 'Cancel', href: '/csv_imports/new?locale=en'

          # After reading the warnings, the user decides
          # to continue with the import.
          click_on 'Start Import'
        end.to_not change { Work.count }
        # The show page for the CsvImport
        expect(page).to have_content 'all_fields_metadata_update.csv'
        expect(page).to have_content 'Start time'

        # We expect to see the title of the collection on the page
        expect(page).to have_content 'Testing Collection'

        # Ensure that all the fields got assigned as expected
        work_one.reload
        expect(work_one.title.first).to match(/Exterior/)
        expect(work_one.file_sets.first.label).to eq('dog.jpg')

        # The show page for the CsvImport
        expect(page).to have_content 'all_fields_metadata_update.csv'
        expect(page).to have_content 'Start time'

        # We expect to see the title of the collection on the page
        expect(page).to have_content 'Testing Collection'

        # Update only new records
        # Let the background jobs run, and check that one additional record has been created
        expect do
          visit '/csv_imports/new'
          expect(page).to have_content 'Testing Collection'
          expect(page).not_to have_content '["Testing Collection"]'
          select 'Testing Collection', from: "csv_import[fedora_collection_id]"

          select 'Ignore Existing Works, new works only', from: 'csv_import[update_actor_stack]'
          # Fill in and submit the form
          attach_file('csv_import[manifest]', csv_only_new_file, make_visible: true)

          click_on 'Preview Import'

          # We expect to see the title of the collection on the page
          expect(page).to have_content 'Testing Collection'

          expect(page).to have_content 'This import will process 2 row(s).'

          # There is a link so the user can cancel.
          expect(page).to have_link 'Cancel', href: '/csv_imports/new?locale=en'


          # After reading the warnings, the user decides
          # to continue with the import.
          click_on 'Start Import'

          # The show page for the CsvImport
          expect(page).to have_content 'all_fields_only_new.csv'
          expect(page).to have_content 'Start time'

          # We expect to see the title of the collection on the page
          expect(page).to have_content 'Testing Collection'
        end.to change { Work.count }.by(1)

        # Ensure that all the fields got assigned as expected
        work_one.reload
        expect(work_one.title.first).to match(/Exterior/)
        expect(work_one.file_sets.first.label).to eq('dog.jpg')

        # Ensure that all the fields got assigned as expected
        work_two = Work.where(title: "*patisserie*").first
        expect(work_two.title.first).to match(/Interior/)
        expect(work_two.file_sets.first.label).to eq('cat.jpg')

        # Update complete
        expect do
          visit '/csv_imports/new'
          expect(page).to have_content 'Testing Collection'
          expect(page).not_to have_content '["Testing Collection"]'
          select 'Testing Collection', from: "csv_import[fedora_collection_id]"

          select 'Overwrite All Files & Metadata', from: 'csv_import[update_actor_stack]'
          # Fill in and submit the form
          attach_file('csv_import[manifest]', csv_complete_update_file, make_visible: true)

          click_on 'Preview Import'

          # We expect to see the title of the collection on the page
          expect(page).to have_content 'Testing Collection'

          expect(page).to have_content 'This import will process 1 row(s).'
          # There is a link so the user can cancel.
          expect(page).to have_link 'Cancel', href: '/csv_imports/new?locale=en'


          # After reading the warnings, the user decides
          # to continue with the import.
          click_on 'Start Import'

          # The show page for the CsvImport
          expect(page).to have_content 'all_fields_complete_update.csv'
          expect(page).to have_content 'Start time'

          # We expect to see the title of the collection on the page
          expect(page).to have_content 'Testing Collection'

          # Let the background jobs run, and check that the expected number of records got created.
        end.to_not change { Work.count }

        # Ensure that all the fields got assigned as expected
        work_two.reload
        expect(work_two.title.first).to match(/Interior/)
        expect(work_two.file_sets.first.label).to eq('cat.jpg')

        # Viewing additional details after an import
        visit "/csv_import_details/index"
        expect(page).to have_content('Total Size')
        click_on "#{Zizia::CsvImportDetail.last.id}"
        click_on 'View Files'
        expect(page).to have_content('dog.jpg')
        expect(page).to have_content('cat.jpg')
        expect(page).to have_content('5.74 MB')
        expect(page).to have_content('abc/123')
        expect(page).to have_content('haberdashery')
        expect(page).to have_content('Date Created')
      end
    end
  end
end
