# frozen_string_literal: true
require 'spec_helper'

require 'zizia/hyrax/hyrax_basic_metadata_mapper'
RSpec.describe Zizia::CsvManifestValidator, type: :model do
  subject(:validator) { described_class.new }
  before :all do
    # patch in a fake initializer
    class Zizia::CsvManifestValidator
      def initialize; end
    end
  end

  it "thinks valid fields is the same as hyraxbasicmetadata.fields" do
    expect(validator.send(:valid_headers).sort).to eq(Zizia::HyraxBasicMetadataMapper.new.headers.map(&:to_s).sort)
  end
end
