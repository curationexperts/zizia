# frozen_string_literal: true
module Zizia
  class PreIngestFile < ApplicationRecord
    belongs_to :pre_ingest_work
  end
end
