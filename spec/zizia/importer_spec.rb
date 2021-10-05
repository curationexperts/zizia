# frozen_string_literal: true

require 'rails_helper'

describe Zizia::Importer do
  subject(:importer) { described_class.new(parser: parser) }
  let(:parser)       { FakeParser.new(file: input) }
  let(:input)        { [{ 'title' => '1' }, { 'title' => '2' }, { 'title' => '3' }] }

  let(:fake_record_importer) do
    Class.new do
      attr_accessor :batch_id, :success_count, :failure_count

      def import(record:)
        records << record.attributes
      end

      def import_all_records(records)
        @work_records = records.select { |record| record.object_type == :work }
        @work_records.each { |record| import(record: record) }
      end

      def records
        @records ||= []
      end
    end
  end

  describe '#records' do
    it 'reflects the parsed records' do
      expect(importer.records.map(&:attributes))
        .to contain_exactly(*parser.records.map(&:attributes))
    end
  end

  describe '#import' do
    let(:record_importer) { fake_record_importer.new }

    before { importer.record_importer = record_importer }

    it 'sends records to the record importer' do
      expect { importer.import }
        .to change { record_importer.records }
        .from(be_empty)
        .to a_collection_containing_exactly(*importer.records.map(&:attributes))
    end
  end
end
