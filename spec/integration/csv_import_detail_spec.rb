# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Using the CsvImportDetail models' do
  let(:user) { User.new }
  let(:csv_import) { Zizia::CsvImport.new }
  let(:csv_import_detail) { Zizia::CsvImportDetail.new }
  let(:pre_ingest_work_one) { Zizia::PreIngestWork.new }
  let(:pre_ingest_work_two) { Zizia::PreIngestWork.new }
  let(:pre_ingest_file_one) do
    Zizia::PreIngestFile.new(row: 'some,row',
                             row_number: 1,
                             size: 1000)
  end
  let(:pre_ingest_file_two) do
    Zizia::PreIngestFile.new(row: 'another,row',
                             row_number: 2,
                             size: 2000)
  end

  it 'allows you to create PreIngestFiles that are associated with PreIngestWorks' do
    pre_ingest_work_one.save

    pre_ingest_work_one.pre_ingest_files << pre_ingest_file_one
    pre_ingest_work_one.pre_ingest_files << pre_ingest_file_two

    expect(pre_ingest_work_one.pre_ingest_files.length).to eq(2)
  end

  it 'allows you to associate PreIngestWorks & Files with a CsvImportDetail' do
    user.save
    csv_import.user = user
    csv_import.save!
    csv_import_detail.csv_import = csv_import
    csv_import_detail.save!

    pre_ingest_work_one.pre_ingest_files << pre_ingest_file_one
    pre_ingest_work_one.pre_ingest_files << pre_ingest_file_two
    csv_import_detail.pre_ingest_works << pre_ingest_work_one
    csv_import_detail.pre_ingest_works << pre_ingest_work_two

    expect(csv_import_detail.pre_ingest_files.length).to eq(2)
    expect(csv_import_detail.pre_ingest_works.length).to eq(2)

    expect(csv_import_detail.total_size).to eq(3000)
  end
end
