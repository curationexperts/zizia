# frozen_string_literal: true

require 'rails/all'
require 'carrierwave'
require 'carrierwave/orm/activerecord'
require 'devise'
require 'hyrax'
require 'riiif'
require 'hydra-role-management'

module Zizia
  class Engine < ::Rails::Engine
    isolate_namespace Zizia

    config.generators do |g|
      g.test_framework :rspec
    end

    initializer :zizia_assets_precompile do |app|
      app.config.assets.precompile << %w[zizia/application.js zizia/application.css]
    end

    initializer "load_features" do
      Flipflop::FeatureLoader.current.append(self)
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match? root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end
  end
end
