require 'rails_helper'

RSpec.describe 'viewing the csv import detail page' do
  let(:user) { FactoryBot.create(:user) }
  let(:csv_import) { FactoryBot.create(:csv_import) }
  let(:csv_import_detail) { FactoryBot.create(:csv_import_detail) }

  it 'displays the metadata when you visit the page' do
    user.save
    csv_import.user_id = user.id
    csv_import.save
    csv_import_detail.save
    visit ('/csv_import_details/index')
    expect(page).to have_content('CSV Imports ID')
    click_on '1'
    expect(page).to have_content('Total Size')
  end
end
