# frozen_string_literal: true
require 'spec_helper'

require 'zizia/hyrax/hyrax_basic_metadata_mapper'
RSpec.describe Zizia::CsvManifestValidator, type: :model do
  subject(:validator) { described_class.new(uploader) }

  let(:uploader) { Zizia::CsvManifestUploader.new }

  before do
    Zizia::CsvManifestUploader.enable_processing = true
    File.open(path_to_file) { |f| uploader.store!(f) }
    validator.parse_csv
  end

  after do
    Zizia::CsvManifestUploader.enable_processing = false
    uploader.remove!
  end

  context "with an object type column" do
    #spec/dummy/spec/fixtures/csv_import/csv_rearranged_headers_new.csv
    let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'csv_import', 'good', 'Postcards_Minneapolis_w_collection.csv') }
    let(:work_row) do
      'w,abc/123,work,https://creativecommons.org/licenses/by/4.0/,abc/123,PUBlic,http://www.geonames.org/5667009/montana.html|~|http://www.geonames.org/6252001/united-states.html,Clothing stores $z California $z Los Angeles|~|Interior design $z California $z Los Angeles,http://rightsstatements.org/vocab/InC/1.0/,"Connell, Will, $d 1898-1961","Interior view of The Bachelors haberdashery designed by Julius Ralph Davidson, Los Angeles, circa 1929",dog.jpg
      '
    end
    let(:collection_row) { 'C,,,,7,Public,,,,,Test collection,' }

    it "thinks valid fields is the same as hyraxbasicmetadata.fields" do
      expect(validator.send(:valid_headers).sort).to eq(Zizia::HyraxBasicMetadataMapper.new.headers.map(&:to_s).sort)
    end

    it "returns required headers based on the object type" do
      expect(validator.required_headers).to eq(['title', 'creator', 'keyword', 'rights_statement', 'visibility', 'files', 'deduplication_key'])
      expect(validator.required_headers("w")).to eq(['title', 'creator', 'keyword', 'rights_statement', 'visibility', 'files', 'deduplication_key'])
      expect(validator.required_headers("c")).to eq(['title', 'visibility'])
    end

    it "returns different required column numbers based on the row" do
      expect(validator.required_column_numbers(work_row)).to eq([1, 3, 6, 18, 19, 20])
      expect(validator.required_column_numbers(collection_row)).to eq([1, 18])
    end
  end
  context "without an object type column" do
    let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'csv_import', 'good', 'all_fields_only_new.csv') }
    let(:work_row) do
      'abc/123,https://creativecommons.org/licenses/by/4.0/,abc/123,PUBlic,http://www.geonames.org/5667009/montana.html|~|http://www.geonames.org/6252001/united-states.html,Clothing stores $z California $z Los Angeles|~|Interior design $z California $z Los Angeles,http://rightsstatements.org/vocab/InC/1.0/,"Connell, Will, $d 1898-1961","Interior view of The Bachelors haberdashery designed by Julius Ralph Davidson, Los Angeles, circa 1929",dog.jpg
    '
    end
    it "still gives required headers and their associated column numbers" do
      expect(validator.required_headers).to eq(['title', 'creator', 'keyword', 'rights_statement', 'visibility', 'files', 'deduplication_key'])
      expect(validator.required_column_numbers(work_row)).to eq([8, 7, 5, 6, 3, 9, 2])
    end
  end
end
