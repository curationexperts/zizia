# frozen_string_literal: true

require 'spec_helper'

describe Zizia::RecordImporter, :clean do
  subject(:importer) do
    described_class.new
  end

  let(:record) { Zizia::InputRecord.from(metadata: metadata) }
  let(:metadata) do
    {
      'title' => 'A Title',
      'language' => 'English',
      'visibility' => 'open'
    }
  end

  it 'raises an error when no work type exists' do
    expect { importer.import(record: record) }
      .to raise_error 'No curation_concern found for import'
  end

  context 'with a registered work type' do
    load File.expand_path("../../support/shared_contexts/with_work_type.rb", __FILE__)
    include_context 'with a work type'

    it 'creates a work for record' do
      expect { importer.import(record: record) }
        .to change { Work.count }
        .by 1
    end

    context 'when input record errors with LDP errors' do
      let(:ldp_error) { Ldp::PreconditionFailed }

      before { allow(record).to receive(:attributes).and_raise(ldp_error) }
      it 'catches the error' do
        expect { importer.import(record: record) }.not_to raise_error(ldp_error)
      end
    end

    context 'when input record errors unexpectedly' do
      let(:custom_error) { Class.new(RuntimeError) }

      before { allow(record).to receive(:attributes).and_raise(custom_error) }

      it 'reraises error' do
        expect { importer.import(record: record) }.to raise_error(custom_error)
      end
    end
  end
end
