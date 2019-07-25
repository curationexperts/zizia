# frozen_string_literal: true

describe Zizia::HashMapper do
  it_behaves_like 'a Zizia::Mapper' do
    let(:expected_fields) { metadata.keys.map(&:to_sym) }
    let(:metadata) { { 'a_field' => 'a', 'b_field' => 'b', 'c_field' => 'c' } }
  end
end
