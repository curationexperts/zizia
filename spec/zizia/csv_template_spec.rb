# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zizia::CsvTemplate do
  let(:csv_template) { described_class.new }

  before do
    Zizia.config.metadata_mapper_class = Zizia::HyraxBasicMetadataMapper
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Zizia::HyraxBasicMetadataMapper).to receive(:fields).and_return([:based_near, :resource_type, :description])
    # rubocop:enable RSpec/AnyInstance
  end

  it 'returns a CSV string based on the headers in the Hyrax mapper' do
    expect(csv_template.to_s).to eq("location,resource type,abstract or summary")
  end
end
