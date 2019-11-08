# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Zizia::PreIngestFile do
  let(:pre_ingest_work) { FactoryBot.create(:pre_ingest_work) }
  let(:pre_ingest_file) { FactoryBot.create(:pre_ingest_file, pre_ingest_work_id: pre_ingest_work.id) }
  let(:pre_ingest_file_without_file) { FactoryBot.create(:pre_ingest_file, pre_ingest_work_id: pre_ingest_work.id, filename: File.open([Zizia::Engine.root, '/', 'spec/fixtures/dog.jpg'].join)) }
  let(:file_set) do
    FactoryBot.create(:file_set,
                      title: ['zizia.png'],
                      content: File.open([Zizia::Engine.root, '/', 'spec/fixtures/zizia.png'].join))
  end
  let(:basename) { 'zizia.png' }

  it 'can get the basename for the file' do
    expect(pre_ingest_file.basename).to eq basename
  end
end
