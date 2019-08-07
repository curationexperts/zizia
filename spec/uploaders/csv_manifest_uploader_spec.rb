# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Zizia::CsvManifestUploader, type: :model do
  subject(:csv_uploader) { described_class.new }

  it 'has a a store dir' do
    expect(csv_uploader.store_dir.to_s).to match(/uploads/)
  end

  it 'has a cache dir' do
    expect(csv_uploader.cache_dir.to_s).to match(/cache/)
  end

  it 'has an extension whitelist' do
    expect(csv_uploader.extension_whitelist).to eq(%w[csv])
  end

  it 'returns an empty array if the validator has no errors' do
    expect(csv_uploader.errors).to eq([])
  end

  it 'has warnings' do
    expect(csv_uploader.warnings).to eq([])
  end

  it 'has records' do
    expect(csv_uploader.records).to eq(0)
  end
end
