# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Zizia::PreIngestWorksController, :clean, type: :controller do
  routes { Zizia::Engine.routes }
  let(:admin_user) { FactoryBot.create(:admin) }
  let(:pre_ingest_work) { FactoryBot.create(:pre_ingest_work) }
  let(:pre_ingest_file) { FactoryBot.create(:pre_ingest_file, pre_ingest_work_id: pre_ingest_work.id) }
  let(:pre_ingest_file_without_file) { FactoryBot.create(:pre_ingest_file, pre_ingest_work_id: pre_ingest_work.id, filename: File.open([Zizia::Engine.root, '/', 'spec/fixtures/dog.jpg'].join)) }
  let(:work) { Work.new(title: ['a title'], deduplication_key: pre_ingest_work.deduplication_key) }
  let(:file_set) do
    FactoryBot.create(:file_set,
                      title: ['zizia.png'],
                      content: File.open([Zizia::Engine.root, '/', 'spec/fixtures/zizia.png'].join))
  end
  let(:basename) { 'zizia.png' }
  before do
    work.ordered_members << file_set
    work.save
  end

  describe 'GET thumbnails' do
    context 'as a logged in user' do
      it 'returns 200' do
        allow(controller).to receive(:current_user).and_return(admin_user)
        get :thumbnails, params: { deduplication_key: pre_ingest_work.deduplication_key, format: :json }
        expect(response.status).to eq(200)
      end

      it 'returns an array of thumbail paths' do
        file_set.save
        allow(controller).to receive(:current_user).and_return(admin_user)
        get :thumbnails, params: { deduplication_key: pre_ingest_work.deduplication_key, format: :json }
        parsed_json = JSON.parse(response.body)
        expect(parsed_json['thumbnails']).to be_an(Array)
        expect(parsed_json['thumbnails'].empty?).to eq(false)
      end

      it 'returns an empty array if there aren\'t any thumbnails' do
        allow(controller).to receive(:current_user).and_return(admin_user)
        get :thumbnails, params: { deduplication_key: 'abc/1234', format: :json }
        parsed_json = JSON.parse(response.body)
        expect(parsed_json['thumbnails']).to be_an(Array)
        expect(parsed_json['thumbnails'].empty?).to eq(true)
      end
    end

    context 'as someone not logged in' do
      it 'returns 401' do
        get :thumbnails, params: { deduplication_key: pre_ingest_work.deduplication_key, format: :json }
        expect(response.status).to eq(401)
      end
    end
  end
end
