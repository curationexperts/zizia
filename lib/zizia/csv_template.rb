# frozen_string_literal: true

module Zizia
  class CsvTemplate
    def to_s
      Zizia.config.metadata_mapper_class.new.headers.join(',')
    end
  end
end
