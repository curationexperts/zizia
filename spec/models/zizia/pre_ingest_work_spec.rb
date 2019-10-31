# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Zizia::PreIngestWork do
  let(:pre_ingest_work) { FactoryBot.create(:pre_ingest_work, deduplication_key: "42") }
  it 'has a deduplication_key' do
    expect(pre_ingest_work.deduplication_key).to eq "42"
  end
end
