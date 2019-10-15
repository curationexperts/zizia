require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'viewing the csv import detail page' do
  let(:csv_import) { FactoryBot.create(:csv_import) }
  let(:csv_import_detail) { FactoryBot.create(:csv_import_detail) }
  let(:user) { FactoryBot.create(:admin) }

  it 'displays the metadata when you visit the page' do
    user.save
    csv_import.user_id = user.id
    csv_import.save
    csv_import_detail.save
    login_as user

    visit ('/csv_import_details/index')
    expect(page).to have_content('CSV Imports ID')
    click_on '1'
    expect(page).to have_content('Total Size')
  end

  it 'has the dashboard layout' do
    user.save
    csv_import.user_id = user.id
    csv_import.save
    csv_import_detail.save
    login_as user

    visit ('/csv_import_details/index')
    expect(page).to have_content('Your activity')
    visit ('csv_import_details/show/1')
    expect(page).to have_content('About the Import')
    expect(page).to have_content('Your activity')
  end
end
