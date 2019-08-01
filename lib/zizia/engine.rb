# frozen_string_literal: true

require 'rails/all'
require 'carrierwave'
require 'carrierwave/orm/activerecord'
require 'redcarpet'

module Zizia
  class Engine < ::Rails::Engine
    isolate_namespace Zizia

    initializer :zizia_assets_precompile do |app|
      app.config.assets.precompile << %w[zizia/application.js zizia/application.css]
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end
  end
end
