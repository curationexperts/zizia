# frozen_string_literal: true
require 'rails_helper'

describe Zizia::HyraxRecordImporter, :perform_jobs, :clean do
  let(:hyrax_record_importer) { described_class.new(attributes: { csv_import_detail: csv_import_detail }) }
  let(:collection) { FactoryBot.create(:collection) }
  let(:user) { FactoryBot.create(:user) }

  let(:record) { Zizia::InputRecord.from(metadata: metadata) }

  let(:csv_import_detail) do
    Zizia::CsvImportDetail.create(csv_import_id: 1, collection_id: collection.id, depositor_id: user.id,
                                  batch_id: 1, deduplication_field: 'identifier', update_actor_stack: 'HyraxDelete')
  end

  context "without an object type in the record" do
    let(:metadata) do
      { 'title' => 'Comet in Moominland',
        'abstract or summary' => 'A book about moomins.',
        'files' => 'dog_3.jpg' }
    end
    context "importing a work" do
      let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: collection.id) }

      around do |example|
        orig_import_path = ENV['IMPORT_PATH']
        ENV['IMPORT_PATH'] = File.join(fixture_path, 'images')
        example.run
        ENV['IMPORT_PATH'] = orig_import_path
      end

      before do
        allow(CharacterizeJob).to receive(:perform_later)
        permission_template
      end

      it "imports a work" do
        expect do
          hyrax_record_importer.import(record: record)
        end.to change { Work.count }.by(1)
      end
    end

    it "defaults to a work" do
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
      expect { hyrax_record_importer.import_type(record) }.to raise_error(RuntimeError, "[zizia] Unrecognized object_type: garbage")
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
  context "with 'f' as the object type in the record" do
    around do |example|
      orig_import_path = ENV['IMPORT_PATH']
      ENV['IMPORT_PATH'] = File.join(fixture_path, 'images')
      example.run
      ENV['IMPORT_PATH'] = orig_import_path
    end

    before do
      allow(CharacterizeJob).to receive(:perform_later)
    end

    let(:metadata) do
      { 'object type' => 'f',
        'abstract or summary' => 'A book about moomins.',
        'files' => 'dog_3.jpg',
        'parent' => 'abc/123' }
    end
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }

    let(:parent_work) { Work.create(title: ["The parent work of my file"], identifier: ['abc/123'], depositor: user.user_key) }

    it "returns File" do
      expect(hyrax_record_importer.import_type(record)).to eq FileSet
    end

    it "can import the file" do
      parent_work
      expect(hyrax_record_importer.import(record: record))
      parent_work.reload
      expect(parent_work.file_sets.first).to be
      expect(parent_work.file_sets.first.files.first).to be_an_instance_of Hydra::PCDM::File
    end
  end

  context "with a full parsed file" do
    around do |example|
      orig_import_path = ENV['IMPORT_PATH']
      ENV['IMPORT_PATH'] = File.join(fixture_path, 'images')
      example.run
      ENV['IMPORT_PATH'] = orig_import_path
    end

    before do
      allow(CharacterizeJob).to receive(:perform_later)
      permission_template
    end
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: collection.id) }

    let(:parser) { Zizia::CsvParser.new(file: file) }
    let(:file) { File.open('spec/dummy/spec/fixtures/csv_import/good/Postcards_-_Minneapolis_UNPACKED.csv') }
    let(:importer) do
      Zizia::Importer.new(
        parser: parser,
        record_importer: hyrax_record_importer
      )
    end
    it "creates an importer" do
      expect(importer).to be_an_instance_of Zizia::Importer
      # rubocop: disable Layout/MultilineMethodCallIndentation
      expect do
        importer.import
      end.to change { Collection.count }.by(1)
         .and change { Work.count }.by(2)
         .and change { FileSet.count }.by(4)
      # rubocop: enable Layout/MultilineMethodCallIndentation
    end

    xit "attaches the files in the correct order" do
      importer.import
      work_one = Work.where(title: "*Canoeing*").first
      expect(work_one.file_sets.first.label).to eq('birds_1.jpg')
      expect(work_one.file_sets.second.label).to eq('cat_2.jpg')
      work_two = Work.where(title: "*flag*").first
      expect(work_two.file_sets.first.label).to eq('dog_3.jpg')
      expect(work_two.file_sets.second.label).to eq('zizia_4.png')
    end
  end
  context "reingesting a collection" do
    around do |example|
      orig_import_path = ENV['IMPORT_PATH']
      ENV['IMPORT_PATH'] = File.join(fixture_path, 'images')
      example.run
      ENV['IMPORT_PATH'] = orig_import_path
    end

    before do
      allow(CharacterizeJob).to receive(:perform_later)
      permission_template
    end

    let(:collection) { FactoryBot.create(:collection, identifier: ['MINNESOTA_POSTCARDS'], deduplication_key: 'MINNESOTA_POSTCARDS', title: ['Awesome Minnesota Postcard Collection'], visibility: 'open') }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: collection.id) }

    let(:parser) { Zizia::CsvParser.new(file: file) }
    let(:file) { File.open('spec/dummy/spec/fixtures/csv_import/good/Postcards_-_Minneapolis_UNPACKED.csv') }
    let(:importer) do
      Zizia::Importer.new(
        parser: parser,
        record_importer: hyrax_record_importer
      )
    end

    it "can import a csv with an existing collection" do
      expect do
        importer.import
        collection.reload
      end.to change { collection.title }.from(['Awesome Minnesota Postcard Collection']).to(['Minnesota Postcard Collection'])
    end

    context "only changing new objects" do
      let(:csv_import_detail) do
        Zizia::CsvImportDetail.create(csv_import_id: 1, collection_id: collection.id, depositor_id: user.id,
                                      batch_id: 1, deduplication_field: 'identifier', update_actor_stack: 'HyraxOnlyNew')
      end

      it "can import a csv with an existing collection" do
        expect do
          importer.import
          collection.reload
          # note: this says it changes, but it keeps the same string value inside the array
        end.to change { collection.title }.from(['Awesome Minnesota Postcard Collection']).to(['Awesome Minnesota Postcard Collection'])
      end
    end
  end
end
