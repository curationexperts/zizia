# frozen_string_literal: true
require 'coveralls'
Coveralls.wear!
require 'pry' unless ENV['CI']

ENV['environment'] ||= 'test'
# Configure Rails Envinronment
ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../spec/dummy/config/environment', __FILE__)
require 'rails/all'
require 'rspec/rails'

ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), '../')

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
