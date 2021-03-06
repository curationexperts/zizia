# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Zizia::PreIngestWork do
  let(:pre_ingest_work) { FactoryBot.create(:pre_ingest_work, deduplication_key: '42') }
  let(:pre_ingest_work_indexed) { FactoryBot.create(:pre_ingest_work, deduplication_key: '43') }
  let(:work) { Work.new(title: ['A Nice Title'], deduplication_key: '43') }

  before do
    work.save
  end

  it 'has a deduplication_key' do
    expect(pre_ingest_work.deduplication_key).to eq '42'
  end

  it 'can return that metadata has not been indexed yet' do
    expect(pre_ingest_work.title).to eq('This work\'s metadata has not been indexed yet.')
  end

  it 'can return a title for a work based on the deduplication key' do
    expect(pre_ingest_work_indexed.title).to eq('A Nice Title')
  end
end
