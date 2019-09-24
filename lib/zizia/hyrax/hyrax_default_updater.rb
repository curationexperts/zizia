# frozen_string_literal: true
module Zizia
  class HyraxDefaultUpdater < HyraxMetadataOnlyUpdater
    attr_reader :attrs

    def actor_stack
      terminator = Hyrax::Actors::Terminator.new
      Hyrax::DefaultMiddlewareStack.build_stack.build(terminator)
    end
  end
end
