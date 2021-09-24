# coding: utf-8
# frozen_string_literal: true
require 'rails_helper'
require 'spec_helper'

describe Zizia::HyraxRecordImporter do
  let(:hyrax_record_importer) { described_class.new(attributes: { csv_import_detail: csv_import_detail }) }
  let(:collection) { FactoryBot.create(:collection, id: 1) }
  let(:user) { FactoryBot.create(:user) }

  let(:record) { Zizia::InputRecord.from(metadata: metadata) }

  let(:csv_import_detail) do
    Zizia::CsvImportDetail.create(csv_import_id: 1, collection_id: collection.id, depositor_id: user.id,
                                  batch_id: 1, deduplication_field: 'identifier', update_actor_stack: 'HyraxDelete')
  end

  context "without an object type in the record" do
    let(:metadata) do
      { 'title' => 'Comet in Moominland',
        'abstract or summary' => 'A book about moomins.' }
    end

    it "ra" do
      expect(hyrax_record_importer.import_type(record)).to eq Work
    end
  end

  context "with 'collection' as the object type in the record" do
    let(:metadata) do
      { 'object type' => 'collection',
        'abstract or summary' => 'A book about moomins.' }
    end

    it "returns Collection" do
      expect(hyrax_record_importer.import_type(record)).to eq Collection
    end
  end

  context "with 'c' as the object type in the record" do
    let(:metadata) do
      { 'object type' => 'c',
        'abstract or summary' => 'A book about moomins.' }
    end

    it "returns Collection" do
      expect(hyrax_record_importer.import_type(record)).to eq Collection
    end
  end

  context "with 'coLLection' as the object type in the record" do
    let(:metadata) do
      { 'object type' => 'coLLection',
        'abstract or summary' => 'A book about moomins.' }
    end

    it "returns Collection" do
      expect(hyrax_record_importer.import_type(record)).to eq Collection
    end
  end

  context "with random stuff as the object type in the record" do
    let(:metadata) do
      { 'object type' => 'garbage',
        'abstract or summary' => 'A book about moomins.' }
    end

    it "raises an error" do
      expect { hyrax_record_importer.import_type(record) }.to raise_error
    end
  end

  context "with an empty string as the object type in the record" do
    let(:metadata) do
      { 'object type' => '',
        'abstract or summary' => 'A book about moomins.' }
    end

    it "defaults to a work" do
      expect(hyrax_record_importer.import_type(record)).to eq Work
    end
  end
end
