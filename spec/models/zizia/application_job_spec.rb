# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Zizia::ApplicationJob do
  let(:application_job) { described_class.new }

  context 'when including Zizia' do
    it 'has its own ApplicationJob class' do
      expect(application_job).to be_kind_of(ActiveJob::Base)
    end
  end
end
