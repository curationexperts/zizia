# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Trying to import a CSV without collections', :clean, type: :system, js: true do
  context 'logged in as an admin user' do
    let(:admin_user) { FactoryBot.create(:admin) }
    let(:test_strategy) { Flipflop::FeatureSet.current.test! }
    
    before do
      login_as admin_user
    end

    context "using the original UI" do
      before do
        test_strategy.switch!(:new_zizia_ui, false)
      end

      it 'displays a warning message' do
        visit '/csv_imports/new'
        expect(page.html.match?(/no-collection/)).to eq(true)
      end
    end

    context "using the new UI" do
      before do
        test_strategy.switch!(:new_zizia_ui, true)
      end

      it 'does not display a warning message' do
        visit '/csv_imports/new'
        expect(page.html.match?(/no-collection/)).to eq(false)
      end
    end
  end
end
