# frozen_string_literal: true

require 'rails_helper'

describe 'importing a csv batch', :clean do
  subject(:importer)              { Zizia::Importer.new(parser: parser) }
  let(:parser)                    { Zizia::CsvParser.new(file: file) }
  let(:file)                      { File.open('spec/fixtures/example.csv') }
  let(:rearranged_header_file)    { File.open('spec/dummy/spec/fixtures/csv_import/csv_rearranged_headers_new.csv') }
  #let(:required_headers)          { Zizia::CsvManifestValidator.required_headers('w') }

  it 'creates a record for each CSV line' do
    expect { importer.import }.to change { Work.count }.to 3
  end

  describe 'validation' do
    context 'with invalid CSV' do
      let(:file) { File.open('spec/fixtures/bad_example.csv') }

      it 'outputs invalid file notice to Rails.logger' do
        expect(Rails.logger).to receive(:error).with("[zizia] CSV::MalformedCSVError: Illegal quoting in line 2. (Zizia::CsvFormatValidator)")
        parser.validate
      end
      it 'verifies required fields come first' do
        puts "left-most fields check here."
        #puts "required headers: #{required_headers}"
      end
    end
  end
end
