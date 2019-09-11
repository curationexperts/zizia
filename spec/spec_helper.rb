# frozen_string_literal: true
require 'coveralls'
Coveralls.wear!('rails')
require 'pry' unless ENV['CI']

ENV['environment'] ||= 'test'
# Configure Rails Envinronment
ENV['RAILS_ENV'] = 'test'

require File.expand_path("../dummy/config/environment", __FILE__)
ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), '../')
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each { |f| require f }

require 'rails/all'
require 'rspec/rails'

ActiveJob::Base.queue_adapter = :test

require 'bundler/setup'
require 'active_fedora'
require 'active_fedora/cleaner'
require 'zizia'
require 'zizia/spec'
require 'byebug'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:each, clean: true) { ActiveFedora::Cleaner.clean! }
end
