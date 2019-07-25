# frozen_string_literal: true

module Zizia
  ##
  # RSpec test support for {Zizia} importers.
  #
  # @see https://relishapp.com/rspec/rspec-core/docs/
  module Spec
    require 'zizia/spec/shared_examples/a_mapper'
    require 'zizia/spec/shared_examples/a_message_stream'
    require 'zizia/spec/shared_examples/a_parser'
    require 'zizia/spec/shared_examples/a_validator'
    require 'zizia/spec/fakes/fake_parser'
  end
end
