# frozen_string_literal: true
require 'spec_helper'

require 'zizia/hyrax/hyrax_basic_metadata_mapper'
RSpec.describe Zizia::CsvManifestValidator, type: :model do
  subject(:validator) { described_class.new(uploader) }

  let(:uploader) { Zizia::CsvManifestUploader.new }
  # let(:required_file_plus_work_headers) { ['title', 'creator', 'keyword', 'rights statement', 'visibility', 'files', 'deduplication_key', 'parent'] }
  # let(:required_work_headers) { ['title', 'creator', 'keyword', 'rights statement', 'visibility', 'files', 'deduplication_key'] }
  # let(:required_collection_headers) { ['title', 'visibility'] }
  # let(:required_file_headers) { ["files", "parent"] }
  let(:required_file_plus_work_headers) { [:title, :creator, :keyword, :rights_statement, :visibility, :files, :deduplication_key, :parent] }
  let(:required_work_headers) { [:title, :creator, :keyword, :rights_statement, :visibility, :files, :deduplication_key] }
  let(:required_collection_headers) { [:title, :visibility] }
  let(:required_file_headers) { [:files, :parent] }
  before do
    Zizia::CsvManifestUploader.enable_processing = true
    File.open(path_to_file) { |f| uploader.store!(f) }
    validator.parse_csv
  end

  after do
    Zizia::CsvManifestUploader.enable_processing = false
    uploader.remove!
  end

  context "with a csv with missing required fields" do
    let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'csv_import', 'csv_files_with_problems', 'row_missing_required_field.csv') }

    it "collects warnings and errors for invalid entries" do
      validator.validate
      expect(validator.errors).to eq(['Missing required metadata in row 3: "Creator" field cannot be blank'])
      expect(validator.warnings).to eq(['The field name "type" is not supported.  This field will be ignored, and the metadata for this field will not be imported.'])
    end
  end

  context "with a csv with the wrong object type" do
    let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'csv_import', 'csv_files_with_problems', 'wrong_object_type.csv') }

    it "collects warnings and errors for invalid entries" do
      validator.validate
      expect(validator.errors).to eq(['Invalid Object Type in row 2: i'])
      expect(validator.warnings).to eq(['The field name "type" is not supported.  This field will be ignored, and the metadata for this field will not be imported.'])
    end
  end

  context "with a csv with a mix of object types" do
    let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'csv_import', 'good', 'mix_of_object_types.csv') }

    it "does not warn or error on a variety of valid object types" do
      validator.validate
      expect(validator.errors).to eq([])
      expect(validator.warnings).to eq([])
    end

    it "collects all the object_types in the file" do
      expect(validator.object_types).to match_array(["collection", "work", "file"])
      expect(validator.required_headers_for_sheet).to match_array(required_file_plus_work_headers)
    end
  end

  context "with a mix of object types missing a field required for only one object type" do
    let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'csv_import', 'csv_files_with_problems', 'mix_of_object_types_missing_header.csv') }

    it "gives an error for the missing header based on having a file row" do
      validator.validate
      expect(validator.errors).to eq(['Missing required column: "Parent".  Your spreadsheet must have this column.'])
      expect(validator.warnings).to eq([])
    end
  end

  context "with a mix of object types missing a value required for only one object type" do
    let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'csv_import', 'csv_files_with_problems', 'mix_of_object_types_missing_parent_for_file.csv') }

    it "gives an error for the missing value based on having a file row" do
      validator.validate
      expect(validator.errors).to eq(['Missing required metadata in row 8: "Parent" field cannot be blank'])
      expect(validator.warnings).to eq([])
    end
  end

  context "with a object type column" do
    let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'csv_import', 'good', 'Postcards_Minneapolis_w_collection.csv') }
    let(:work_row) do
      'w,abc/123,work,https://creativecommons.org/licenses/by/4.0/,abc/123,PUBlic,http://www.geonames.org/5667009/montana.html|~|http://www.geonames.org/6252001/united-states.html,Clothing stores $z California $z Los Angeles|~|Interior design $z California $z Los Angeles,http://rightsstatements.org/vocab/InC/1.0/,"Connell, Will, $d 1898-1961","Interior view of The Bachelors haberdashery designed by Julius Ralph Davidson, Los Angeles, circa 1929",dog.jpg
      '
    end
    let(:collection_row) { 'C,,,,7,Public,,,,,Test collection,' }

    it "thinks valid fields is the same as hyraxbasicmetadata.fields" do
      valid_headers = [:abstract_or_summary, :bibliographic_citation, :contributor, :creator, :date_created, :deduplication_key, :files, :identifier, :keyword, :language, :license, :location, :object_type, :parent, :publisher, :related_url, :resource_type, :rights_statement, :source, :subject, :title, :visibility]
      expect(validator.send(:valid_headers).sort).to match_array(valid_headers)
    end

    it "collects all the object_types in the file" do
      expect(validator.object_types).to eq(["work", "collection"])
      expect(validator.required_headers_for_sheet).to match_array(required_work_headers)
    end

    it "returns required headers based on the object type" do
      expect(validator.required_headers).to eq(required_work_headers)
      expect(validator.required_headers("w")).to eq(required_work_headers)
      expect(validator.required_headers("c")).to eq(required_collection_headers)
      expect(validator.required_headers("Collection")).to eq(required_collection_headers)
      expect(validator.required_headers("CoLLection")).to eq(required_collection_headers)
      expect(validator.required_headers("wOrk")).to eq(required_work_headers)
      expect(validator.required_headers('garbage')).to eq(required_work_headers)
      expect(validator.required_headers('')).to eq(required_work_headers)
      expect(validator.required_headers('file')).to eq(required_file_headers)
    end

    it "returns different required column numbers based on the row" do
      expect(validator.required_column_numbers(work_row)).to eq([1, 3, 6, 8, 18, 19, 20])
      expect(validator.required_column_numbers(collection_row)).to eq([1, 18])
    end
  end

  context "without an object type column and empty rows" do
    let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'csv_import', 'good', 'all_fields_only_new.csv') }
    let(:work_row) do
      'abc/123,https://creativecommons.org/licenses/by/4.0/,abc/123,PUBlic,http://www.geonames.org/5667009/montana.html|~|http://www.geonames.org/6252001/united-states.html,Clothing stores $z California $z Los Angeles|~|Interior design $z California $z Los Angeles,http://rightsstatements.org/vocab/InC/1.0/,"Connell, Will, $d 1898-1961","Interior view of The Bachelors haberdashery designed by Julius Ralph Davidson, Los Angeles, circa 1929",dog.jpg
    '
    end
    it "still gives required headers and their associated column numbers" do
      expect(validator.required_headers).to match_array(required_work_headers)
      expect(validator.required_column_numbers(work_row)).to eq([8, 7, 5, 6, 3, 9, 2])
    end

    it "still validates the file" do
      validator.validate
      expect(validator.errors).to eq([])
      expect(validator.warnings).to eq([])
    end

    it "still gives the expected headers" do
      sheet_headers = [:identifier, :license, :deduplication_key, :visibility, :location, :keyword, :rights_statement, :creator, :title, :files]
      expect(validator.headers). to match_array(sheet_headers)
    end
  end

  context "with files for a work on a separate row" do
    let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'csv_import', 'good', 'many_files.csv') }

    it "still gives required headers for entire sheet" do
      expect(validator.required_headers_for_sheet).to match_array(required_file_plus_work_headers)
    end

    it "does not require a file row value for a work if the files are on a separate row" do
      pending("Validating the CSV file as a whole")
      validator.validate
      expect(validator.errors).to eq([])
      expect(validator.warnings).to eq([])
    end
  end

  context "with duplicate headers" do
    let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'csv_import', 'csv_files_with_problems', 'duplicate_headers.csv') }
    it "gives a warning for duplicate headers" do
      validator.validate
      expect(validator.errors).to match_array(['Duplicate column names: You can have only one "Parent" column.'])
      expect(validator.warnings).to eq([])
    end
  end
end
