# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Zizia::CsvImportDetail do
  it 'can instantiate' do
    cid = described_class.new
    expect(cid.class).to eq described_class
  end
end
