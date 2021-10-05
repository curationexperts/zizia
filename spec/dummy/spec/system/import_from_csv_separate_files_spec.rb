# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Importing records from a CSV file', :perform_jobs, clean: true, type: :system, js: true do
  before do
    allow(CharacterizeJob).to receive(:perform_later)
  end

  around do |example|
    orig_import_path = ENV['IMPORT_PATH']
    ENV['IMPORT_PATH'] = File.join(fixture_path, 'images')
    example.run
    ENV['IMPORT_PATH'] = orig_import_path
  end

  let(:csv_file) { File.join(fixture_path, 'csv_import', 'good', 'many_files.csv') }
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
          expect(page).to have_content('You sucessfully uploaded this CSV: many_files.csv')

          click_on 'Preview Import'

          expect(page).to have_content 'This import will process 6 row(s).'
          expect(page).to have_button('Start Import')
          click_on 'Start Import'
        end.to change { Work.count }.by(1)
            .and change { Collection.count }.by(1)
            .and change { FileSet.count }.by(4)

        # The show page for the CsvImport
        expect(page).to have_content 'many_files.csv'
        expect(page).to have_content 'Start time'

        # Ensure that all the fields got assigned as expected
        work_one = Work.where(title: "*tomatoes*").first
        expect(work_one.title.first).to match(/tomatoes/)
      end
    end
  end
end
