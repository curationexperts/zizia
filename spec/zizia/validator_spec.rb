# frozen_string_literal: true

require 'spec_helper'

describe Zizia::Validator do
  it_behaves_like 'a Zizia::Validator' do
    let(:valid_parser) { :any }
  end
end
