require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'viewing the csv import detail page' do
  let(:csv_import) { FactoryBot.create(:csv_import) }
  let(:csv_import_detail) { FactoryBot.create_list(:csv_import_detail, 12, created_at: Time.parse('Tue, 29 Oct 2019 14:20:02 UTC +00:00').utc) }
  let(:csv_import_detail_second) { FactoryBot.create(:csv_import_detail, created_at: Time.parse('Thur, 31 Oct 2019 14:20:02 UTC +00:00').utc, status: 'zippy', update_actor_stack: 'ZiziaTesting')  }
  let(:user) { FactoryBot.create(:admin) }

  before do
    user.save
    csv_import.user_id = user.id
    csv_import.save
    csv_import_detail.each(&:save)
    csv_import_detail_second.save
    login_as user
  end

  it 'displays the metadata when you visit the page' do
    visit ('/csv_import_details/index')
    expect(page).to have_content('CSV Imports ID')
    expect(page).to have_content('Status')
    expect(page).to have_content('undetermined')
    click_on '1'
    expect(page).to have_content('Total Size')
  end

  it 'has links to sort' do
    visit ('/csv_import_details/index')
    expect(page).to have_content ('Unknown')
    click_on('Date')
    expect(page.current_url).to match(/index\?direction\=asc\&locale\=en\&sort\=created_at/)
    expect(page).not_to have_content('Unknown')
    visit('/csv_import_details/index?direction=desc&locale=en&sort=created_at')
    expect(page).to have_content('Unknown')
  end

  it 'has a sortable id' do
    visit('/csv_import_details/index?direction=desc&locale=en&sort=id')
    expect(page).to have_link '13'
  end

  it 'has a sortable status' do
    pending 'status is always undetermined currently'
    visit('/csv_import_details/index?direction=asc&locale=en&sort=status')
    expect(page).to have_content 'zippy'
  end

  it 'has a sortable date' do
    visit('/csv_import_details/index?direction=desc&locale=en&sort=created_at')
    expect(page).to have_content 'October 31'
  end

  it 'displays the metadata when you visit the page' do
    visit ('/csv_import_details/index')
    expect(page).to have_content('CSV Imports ID')
    click_on '1'
    expect(page).to have_content('Total Size')
  end

  it 'displays the created_at date' do
    visit ('/csv_import_details/index')
    expect(page).to have_content('Date')
    expect(page).to have_content('October 29, 2019 14:20')
  end

  it 'displays undetermined for the status' do
    visit ('/csv_import_details/index')
    expect(page).to have_content('Status')
    expect(page).to have_content('undetermined')
  end

  it 'displays the overwrite behavior type' do
    visit ('/csv_import_details/index')
    expect(page).to have_content('Overwrite Behavior Type')
    expect(page).to have_content('Update Existing Metadata, create new works')
  end

  it 'has the dashboard layout' do
    visit ('/csv_import_details/index')
    expect(page).to have_content('Your activity')
    visit ('csv_import_details/show/1')
    expect(page).to have_content('About the Import')
    expect(page).to have_content('Your activity')

    visit('/csv_import_details/index')
    expect(page).to have_content('Next')
  end

  it 'has pagination at 10' do
    visit('/csv_import_details/index')
    expect(page).to have_content('Next')
    click_on 'Next'
    expect(page).to have_content('Previous')
  end
end
