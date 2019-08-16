# frozen_string_literal: true

module Zizia
  class CsvTemplate
    def to_s
      Zizia.config.metadata_mapper_class.new.fields.join(',')
    end
  end
end
