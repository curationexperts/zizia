# frozen_string_literal: true

module Zizia
  class MetadataUsage
    include Singleton

    def usage
      YAML.load_file(config)
    end

    private

    def default_location
      File.join(File.dirname(__FILE__), '../../config/zizia/usage.yml')
    end

    def config
      return default_location unless File.exist?(Rails.root.join("config", "zizia", "usage.yml"))
      Rails.root.join("config", "zizia", "usage.yml")
    end
  end
end
