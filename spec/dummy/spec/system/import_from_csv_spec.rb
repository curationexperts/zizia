# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Importing records from a CSV file', :perform_jobs, :clean, type: :system, js: true do
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
        Collection.destroy_all
      end

      it 'starts the import' do
        visit '/csv_imports/new'
        expect(page).not_to have_content 'Testing Collection'
        expect(page).not_to have_content '["Testing Collection"]'

        # Fill in and submit the form
        select 'Update Existing Metadata, create new works', from: "csv_import[update_actor_stack]"
        attach_file('csv_import[manifest]', csv_file, make_visible: true)

        expect(page).to have_content('You sucessfully uploaded this CSV: all_fields.csv')

        click_on 'Preview Import'

        expect(page).to have_content 'This import will process 2 row(s).'

        # There is a link so the user can cancel.
        expect(page).to have_link 'Cancel', href: '/csv_imports/new?locale=en'

        expect(page).not_to have_content('The field name "object type" is not supported.')

        # After reading the warnings, the user decides
        # to continue with the import.
        click_on 'Start Import'

        # The show page for the CsvImport
        expect(page).to have_content 'all_fields.csv'
        expect(page).to have_content 'Start time'

        expect(Work.count).to eq 1

        # Ensure that all the fields got assigned as expected
        work = Work.where(title: "*haberdashery*").first
        expect(work.title.first).to match(/haberdashery/)

        # Ensure location (a.k.a. based_near) gets turned into a controlled vocabulary term
        expect(work.based_near.first.class).to eq Hyrax::ControlledVocabularies::Location

        # It sets the date_uploaded field
        expect(work.date_uploaded.class).to eq DateTime

        # Ensure visibility gets turned into expected Hyrax values (e.g., 'PUBlic' becomes 'open')
        expect(work.visibility).to eq 'open'

        # Ensure work is being added to the collection as expected
        # expect(work.member_of_collection_ids).to eq [collection.id]

        visit "/concern/works/#{work.id}"
        expect(page).to have_content work.title.first
        # Controlled vocabulary location should have been resolved to its label name
        expect(page).to have_content "Los Angeles"

        # The license value resolves to a controlled field from creative commons
        expect(page).to have_link "Attribution 4.0"


        # Updating

        visit '/csv_imports/new'
        select 'Update Existing Metadata, create new works', from: "csv_import[update_actor_stack]"

        # Fill in and submit the form
        attach_file('csv_import[manifest]', csv_metadata_update_file, make_visible: true)

        click_on 'Preview Import'

        expect(page).to have_content 'This import will process 1 row(s).'
        # There is a link so the user can cancel.
        expect(page).to have_link 'Cancel', href: '/csv_imports/new?locale=en'

        # After reading the warnings, the user decides
        # to continue with the import.
        click_on 'Start Import'

        # The show page for the CsvImport
        expect(page).to have_content 'all_fields_metadata_update.csv'
        expect(page).to have_content 'Start time'

        # Let the background jobs run, and check that the expected number of records got created.
        expect(Work.count).to eq 1

        # Ensure that all the fields got assigned as expected
        work = Work.where(title: "*haberdashery*").first
        expect(work.title.first).to match(/Exterior/)
        expect(work.file_sets.first.label).to eq('dog.jpg')

        # The show page for the CsvImport
        expect(page).to have_content 'all_fields_metadata_update.csv'
        expect(page).to have_content 'Start time'

        # Let the background jobs run, and check that the expected number of records got created.
        expect(Work.count).to eq 1

        # Ensure that all the fields got assigned as expected
        work = Work.where(title: "*haberdashery*").first
        expect(work.title.first).to match(/Exterior/)
        expect(work.file_sets.first.label).to eq('dog.jpg')


        # Update only new records

        visit '/csv_imports/new'

        select 'Ignore Existing Works, new works only', from: 'csv_import[update_actor_stack]'
        # Fill in and submit the form
        attach_file('csv_import[manifest]', csv_only_new_file, make_visible: true)

        click_on 'Preview Import'

        expect(page).to have_content 'This import will process 2 row(s).'

        # There is a link so the user can cancel.
        expect(page).to have_link 'Cancel', href: '/csv_imports/new?locale=en'


        # After reading the warnings, the user decides
        # to continue with the import.
        click_on 'Start Import'

        # The show page for the CsvImport
        expect(page).to have_content 'all_fields_only_new.csv'
        expect(page).to have_content 'Start time'

        # Let the background jobs run, and check that the expected number of records got created.
        expect(Work.count).to eq 2

        # Ensure that all the fields got assigned as expected
        work = Work.where(title: "*haberdashery*").first
        expect(work.title.first).to match(/Exterior/)
        expect(work.file_sets.first.label).to eq('dog.jpg')

        # Ensure that all the fields got assigned as expected
        work = Work.where(title: "*patisserie*").first
        expect(work.title.first).to match(/Interior/)
        expect(work.file_sets.first.label).to eq('cat.jpg')


        # Update complete

        visit '/csv_imports/new'

        select 'Overwrite All Files & Metadata', from: 'csv_import[update_actor_stack]'
        # Fill in and submit the form
        attach_file('csv_import[manifest]', csv_complete_update_file, make_visible: true)

        click_on 'Preview Import'

        expect(page).to have_content 'This import will process 1 row(s).'
        # There is a link so the user can cancel.
        expect(page).to have_link 'Cancel', href: '/csv_imports/new?locale=en'

        # After reading the warnings, the user decides
        # to continue with the import.
        click_on 'Start Import'

        # The show page for the CsvImport
        expect(page).to have_content 'all_fields_complete_update.csv'
        expect(page).to have_content 'Start time'

        # Let the background jobs run, and check that the expected number of records got created.
        expect(Work.count).to eq 2

        # Ensure that all the fields got assigned as expected
        work = Work.where(title: "*haberdashery*").first
        expect(work.title.first).to match(/Interior/)
        expect(work.file_sets.first.label).to eq('cat.jpg')

        # Viewing additional details after an import
        visit "/csv_import_details/index"
        expect(page).to have_content('Total Size')
        click_on '4'
        click_on 'View Files'
        expect(page).to have_content('dog.jpg')
        expect(page).to have_content('cat.jpg')
        expect(page).to have_content('5.74 MB')
        expect(page).to have_content('abc/123')
        expect(page).to have_content('haberdashery')
        expect(page).to have_content('Date Created')
      end
    end
    context 'using the old UI' do
      let(:collection) { FactoryBot.build(:collection, title: ['Testing Collection']) }

      before do
        test_strategy.switch!(:new_zizia_ui, false)

        collection.save!
      end

      it 'starts the import' do
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

        # TO-DO: Determine how to get the background jobs working with the dummy
        # Let the background jobs run, and check that the expected number of records got created.
        expect(Work.count).to eq 1

        # Ensure that all the fields got assigned as expected
        work = Work.where(title: "*haberdashery*").first
        expect(work.title.first).to match(/haberdashery/)

        # Ensure location (a.k.a. based_near) gets turned into a controlled vocabulary term
        expect(work.based_near.first.class).to eq Hyrax::ControlledVocabularies::Location

        # It sets the date_uploaded field
        expect(work.date_uploaded.class).to eq DateTime

        # Ensure visibility gets turned into expected Hyrax values (e.g., 'PUBlic' becomes 'open')
        expect(work.visibility).to eq 'open'

        # Ensure work is being added to the collection as expected
        expect(work.member_of_collection_ids).to eq [collection.id]

        visit "/concern/works/#{work.id}"
        expect(page).to have_content work.title.first
        # Controlled vocabulary location should have been resolved to its label name
        expect(page).to have_content "Los Angeles"

        # The license value resolves to a controlled field from creative commons
        expect(page).to have_link "Attribution 4.0"


        # Updating

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

        # The show page for the CsvImport
        expect(page).to have_content 'all_fields_metadata_update.csv'
        expect(page).to have_content 'Start time'

        # We expect to see the title of the collection on the page
        expect(page).to have_content 'Testing Collection'

        # Let the background jobs run, and check that the expected number of records got created.
        expect(Work.count).to eq 1

        # Ensure that all the fields got assigned as expected
        work = Work.where(title: "*haberdashery*").first
        expect(work.title.first).to match(/Exterior/)
        expect(work.file_sets.first.label).to eq('dog.jpg')

        # The show page for the CsvImport
        expect(page).to have_content 'all_fields_metadata_update.csv'
        expect(page).to have_content 'Start time'

        # We expect to see the title of the collection on the page
        expect(page).to have_content 'Testing Collection'

        # Let the background jobs run, and check that the expected number of records got created.
        expect(Work.count).to eq 1

        # Ensure that all the fields got assigned as expected
        work = Work.where(title: "*haberdashery*").first
        expect(work.title.first).to match(/Exterior/)
        expect(work.file_sets.first.label).to eq('dog.jpg')


        # Update only new records

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

        # Let the background jobs run, and check that the expected number of records got created.
        expect(Work.count).to eq 2

        # Ensure that all the fields got assigned as expected
        work = Work.where(title: "*haberdashery*").first
        expect(work.title.first).to match(/Exterior/)
        expect(work.file_sets.first.label).to eq('dog.jpg')

        # Ensure that all the fields got assigned as expected
        work = Work.where(title: "*patisserie*").first
        expect(work.title.first).to match(/Interior/)
        expect(work.file_sets.first.label).to eq('cat.jpg')


        # Update complete

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
        expect(Work.count).to eq 2

        # Ensure that all the fields got assigned as expected
        work = Work.where(title: "*haberdashery*").first
        expect(work.title.first).to match(/Interior/)
        expect(work.file_sets.first.label).to eq('cat.jpg')

        # Viewing additional details after an import
        visit "/csv_import_details/index"
        expect(page).to have_content('Total Size')
        click_on '4'
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
