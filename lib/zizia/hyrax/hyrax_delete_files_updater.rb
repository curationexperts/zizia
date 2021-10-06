# frozen_string_literal: true
module Zizia
  class HyraxDeleteFilesUpdater < HyraxMetadataOnlyUpdater
    attr_reader :attrs

    def actor_stack
      terminator = Hyrax::Actors::Terminator.new
      Hyrax::DefaultMiddlewareStack.build_stack.build(terminator)
    end

    def update
      existing_record.file_sets.map(&:destroy)
      super
    end
  end
end
