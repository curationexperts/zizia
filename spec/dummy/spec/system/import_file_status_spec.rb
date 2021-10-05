# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Importing records from a CSV file', :perform_jobs, :clean, type: :system, js: true do
  let(:test_strategy) { Flipflop::FeatureSet.current.test! }

  before do
    allow(CharacterizeJob).to receive(:perform_later)
  end

  around do |example|
    orig_import_path = ENV['IMPORT_PATH']
    ENV['IMPORT_PATH'] = File.join(fixture_path, 'images')
    example.run
    ENV['IMPORT_PATH'] = orig_import_path
  end

  let(:csv_file) { File.join(fixture_path, 'csv_import', 'good', 'all_fields_multi.csv') }

  context 'logged in as an admin user' do
    let(:admin_user) { FactoryBot.create(:admin) }

    before do
      login_as admin_user
    end
    context 'with the new ui' do
      let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
      let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
      let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }
      before do
        test_strategy.switch!(:new_zizia_ui, true)
        # Create a single action that can be taken
        Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

        # Grant the user access to deposit into the admin set.
        Hyrax::PermissionTemplateAccess.create!(
          permission_template_id: permission_template.id,
          agent_type: 'user',
          agent_id: admin_user.user_key,
          access: 'deposit'
        )

        Collection.destroy_all
      end

      it 'starts the import' do
        visit '/csv_imports/new'
        expect(page).not_to have_content 'Testing Collection'
        expect(page).not_to have_content '["Testing Collection"]'

        # Fill in and submit the form
        select 'Update Existing Metadata, create new works', from: "csv_import[update_actor_stack]"
        attach_file('csv_import[manifest]', csv_file, make_visible: true)

        expect(page).to have_content('You sucessfully uploaded this CSV: all_fields_multi.csv')

        click_on 'Preview Import'

        # We expect to see the title of the collection on the page

        expect(page).to have_content 'This import will process 1 row(s).'

        # There is a link so the user can cancel.
        expect(page).to have_link 'Cancel', href: '/csv_imports/new?locale=en'

        expect(page).not_to have_content 'deduplication_key'

        # After reading the warnings, the user decides
        # to continue with the import.
        expect(page).to have_button('Start Import')
        click_on 'Start Import'

        # The show page for the CsvImport
        expect(page).to have_content 'all_fields_multi.csv'
        expect(page).to have_content 'Start time'

        # We expect to see the title of the collection on the page
        expect(Work.count).to eq 1

        # Ensure that all the fields got assigned as expected
        work = Work.where(title: "*haberdashery*").first
        expect(work.title.first).to match(/haberdashery/)
        expect(Zizia::PreIngestFile.last.status).to eq('attached')

        expect(Zizia::PreIngestWork.find_by(deduplication_key: work.deduplication_key).pre_ingest_files.count).to eq(2)

        # Everything should have the attached status now
        expect(Zizia::PreIngestWork.find_by(deduplication_key: work.deduplication_key)
                 .pre_ingest_files.first.status).to eq('attached')
        expect(Zizia::PreIngestWork.find_by(deduplication_key: work.deduplication_key).pre_ingest_files.last.status).to eq('attached')
        expect(Zizia::PreIngestWork.find_by(deduplication_key: work.deduplication_key).status).to eq('attached')
        visit('/csv_import_details/index')
        click_on '1'
        expect(page).to have_content 'View Files'
        click_on 'View Files'
        expect(page.html).not_to match(/glyphicon-question-sign/)
        expect(page.html).to match(/glyphicon-ok-sign/)
        expect(page).to have_content('dog.jpg')
        expect(page).to have_content('cat.jpg')
      end
    end
    context 'with the old ui' do
      let(:collection) { FactoryBot.build(:collection, title: ['Testing Collection']) }

      let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
      let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
      let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

      before do
        test_strategy.switch!(:new_zizia_ui, false)
        # Create a single action that can be taken
        Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

        # Grant the user access to deposit into the admin set.
        Hyrax::PermissionTemplateAccess.create!(
          permission_template_id: permission_template.id,
          agent_type: 'user',
          agent_id: admin_user.user_key,
          access: 'deposit'
        )

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

        expect(page).to have_content('You sucessfully uploaded this CSV: all_fields_multi.csv')

        click_on 'Preview Import'

        # We expect to see the title of the collection on the page
        expect(page).to have_content 'Testing Collection'

        expect(page).to have_content 'This import will process 1 row(s).'

        # There is a link so the user can cancel.
        expect(page).to have_link 'Cancel', href: '/csv_imports/new?locale=en'

        expect(page).not_to have_content 'deduplication_key'

        # After reading the warnings, the user decides
        # to continue with the import.
        expect(page).to have_button('Start Import')
        click_on 'Start Import'

        # The show page for the CsvImport
        expect(page).to have_content 'all_fields_multi.csv'
        expect(page).to have_content 'Start time'

        # We expect to see the title of the collection on the page
        expect(page).to have_content 'Testing Collection'
        expect(Work.count).to eq 1

        # Ensure that all the fields got assigned as expected
        work = Work.where(title: "*haberdashery*").first
        expect(work.title.first).to match(/haberdashery/)
        expect(Zizia::PreIngestFile.last.status).to eq('attached')

        expect(Zizia::PreIngestWork.find_by(deduplication_key: work.deduplication_key).pre_ingest_files.count).to eq(2)

        # Everything should have the attached status now
        expect(Zizia::PreIngestWork.find_by(deduplication_key: work.deduplication_key)
                 .pre_ingest_files.first.status).to eq('attached')
        expect(Zizia::PreIngestWork.find_by(deduplication_key: work.deduplication_key).pre_ingest_files.last.status).to eq('attached')
        expect(Zizia::PreIngestWork.find_by(deduplication_key: work.deduplication_key).status).to eq('attached')
        visit('/csv_import_details/index')
        click_on '1'
        expect(page).to have_content 'View Files'
        click_on 'View Files'
        expect(page.html).not_to match(/glyphicon-question-sign/)
        expect(page.html).to match(/glyphicon-ok-sign/)
        expect(page).to have_content('dog.jpg')
        expect(page).to have_content('cat.jpg')
      end
    end
  end
end
