# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Zizia::PreIngestWork, clean: true do
  let(:pre_ingest_work) { FactoryBot.create(:pre_ingest_work, deduplication_key: '42', collection_id: collection.id) }
  let(:pre_ingest_work_indexed) { FactoryBot.create(:pre_ingest_work, deduplication_key: '43') }
  let(:collection) { FactoryBot.build(:collection, title: ['Testing Collection'], identifier: ['def/123']) }
  let(:work) { Work.new(title: ['A Nice Title'], deduplication_key: '43') }

  before do
    work.member_of_collections = [collection]
    work.save
  end

  it 'has a deduplication_key' do
    expect(pre_ingest_work.deduplication_key).to eq '42'
  end

  it 'has collection_ids' do
    expect(work.member_of_collection_ids).to eq [collection.id]
    expect(pre_ingest_work.collection_id).to eq collection.id
    expect(pre_ingest_work.collection_identifier).to eq collection.identifier.first
    expect(pre_ingest_work.collection_title).to eq 'Testing Collection'
  end

  it 'only looks up the collection once to return both title and identifier' do
    notifier = class_double("Collection")
               .as_stubbed_const(transfer_nested_constants: true)
    # rubocop: disable RSpec/MessageSpies
    expect(notifier).to receive(:find).with(collection.id).and_return(collection)
    pre_ingest_work.collection_id
    pre_ingest_work.collection_identifier
    pre_ingest_work.collection_title
    # rubocop: enable RSpec/MessageSpies
  end

  it 'can return that metadata has not been indexed yet' do
    expect(pre_ingest_work.title).to eq('This work\'s metadata has not been indexed yet.')
  end

  it 'can return a title for a work based on the deduplication key' do
    expect(pre_ingest_work_indexed.title).to eq('A Nice Title')
    expect(pre_ingest_work_indexed.collection_title).to be nil
  end

  context 'when the associated collection has been deleted' do
    before do
      Collection.all.destroy_all
    end
    it 'returns that the collection has been deleted' do
      expect(Collection.count).to eq 0
      expect(pre_ingest_work.collection_title).to eq("The associated collection has been deleted.")
      expect(pre_ingest_work.collection_identifier).to eq('deleted')
    end
  end
end
