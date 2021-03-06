# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zizia::CsvTemplate do
  let(:csv_template) { described_class.new }

  before do
    Zizia.config.metadata_mapper_class = Zizia::HyraxBasicMetadataMapper
  end

  it 'returns a CSV string based on the headers in the Hyrax mapper' do
    expect(csv_template.to_s).to eq(Zizia::HyraxBasicMetadataMapper.new.fields.join(','))
  end
end
