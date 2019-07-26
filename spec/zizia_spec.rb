# frozen_string_literal: true

require 'spec_helper'

class FakeMetadataMapper
end

describe Zizia do
  describe '#config' do
    it 'can set a default error stream' do
      expect { described_class.config { |c| c.default_error_stream = STDOUT } }
        .to change { described_class.config.default_error_stream }
        .to(STDOUT)
    end

    it 'can set a default info stream' do
      expect { described_class.config { |c| c.default_info_stream = STDOUT } }
        .to change { described_class.config.default_info_stream }
        .to(STDOUT)
    end

    it 'has a default metadata mapper' do
      expect(described_class.config.metadata_mapper_class).to eq Zizia::HyraxBasicMetadataMapper
    end

    it 'can set a default metadata mapper' do
      expect { described_class.config { |c| c.metadata_mapper_class = FakeMetadataMapper } }
        .to change { described_class.config.metadata_mapper_class }
        .to(FakeMetadataMapper)
    end
  end
end
