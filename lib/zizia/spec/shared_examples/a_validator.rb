# frozen_string_literal: true

shared_examples 'a Zizia::Validator' do
  subject(:validator) { described_class.new }

  define :be_a_validator_error do # |expected|
    match { false } # { |actual| some_condition }
  end

  describe '#validate' do
    context 'without a parser' do
      it 'raises ArgumentError' do
        expect { validator.validate }.to raise_error ArgumentError
      end
    end

    it 'gives an empty error collection for a valid parser' do
      expect(validator.validate(parser: valid_parser)).not_to be_any if
        defined?(valid_parser)
    end

    context 'for an invalid parser' do
      it 'gives an non-empty error collection' do
        expect(validator.validate(parser: invalid_parser)).to be_any if
          defined?(invalid_parser)
      end
    end
  end
end
