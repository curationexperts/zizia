# frozen_string_literal: true
module Zizia
  class PreIngestWork < ApplicationRecord
    has_many :pre_ingest_files
  end
end
