require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'viewing the csv import detail page' do
  let(:csv_import) { FactoryBot.create(:csv_import) }
  let(:csv_import_detail) { FactoryBot.create_list(:csv_import_detail, 12, created_at: Time.parse('Tue, 29 Oct 2019 14:20:02 UTC +00:00').utc) }
  let(:user) { FactoryBot.create(:admin) }

  before do
    user.save
    csv_import.user_id = user.id
    csv_import.save
    csv_import_detail.each(&:save)
    login_as user
  end

  it 'displays the metadata when you visit the page' do
    visit ('/csv_import_details/index')
    expect(page).to have_content('CSV Imports ID')
    click_on '1'
    expect(page).to have_content('Total Size')
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
