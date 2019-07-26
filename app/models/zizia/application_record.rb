# frozen_string_literal: true
module Zizia
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
