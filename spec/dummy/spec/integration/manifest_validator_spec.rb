# frozen_string_literal: true

require 'rails_helper'

describe 'validating manifest headers', :clean do
  let(:parser)       { Zizia::CsvParser.new(file: starred_file) }
  let(:file)         { File.open('spec/fixtures/example.csv') }
  let(:starred_file) { File.open('spec/dummy/spec/fixtures/csv_import/csv_rearranged_headers_new.csv') }

  it 'checks transformed headers' do 
    puts 'yup'
  end

  describe 'validation' do
    context 'with valid csv' do
      let(:starred_file) { File.open('spec/dummy/spec/fixtures/csv_import/csv_rearranged_headers_new.csv') }
      it 'reports that file is valid' do
        expect(Rails.logger).not_to receive(:error).with("[zizia] CSV::MalformedCSVError: Illegal quoting in line 2. (Zizia::CsvFormatValidator)")
        parser.validate
      end
    end
  end
end
