# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Zizia::CsvImport, type: :model do
  subject(:csv_import) { described_class.new }

  it 'has a CSV manifest' do
    expect(csv_import.manifest).to be_a Zizia::CsvManifestUploader
  end

  context '#queue_start_job' do
    it 'queues a job to start the import' do
      expect do
        csv_import.queue_start_job
      end.to have_enqueued_job(Zizia::StartCsvImportJob)
    end
  end
end
