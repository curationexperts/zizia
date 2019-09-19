# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'zizia/version'

Gem::Specification.new do |gem|
  gem.name          = 'zizia'
  gem.version       = Zizia::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ['Data Curation Experts']
  gem.email         = ['administrator@curationexperts.com']
  gem.summary       = 'Hyrax importers.'
  gem.license       = 'Apache-2.0'
  gem.files         = %w[AUTHORS CHANGELOG.md README.md LICENSE] +
                      Dir.glob('lib/**/*.rb')
  gem.require_paths = %w[lib]

  gem.required_ruby_version = '>= 2.3.4'

  gem.add_dependency 'active-fedora'
  gem.add_dependency 'rails', '~> 5.1.4'
  gem.add_dependency 'carrierwave'
  gem.add_dependency 'redcarpet'
  gem.add_development_dependency 'bixby'
  gem.add_dependency 'bootstrap-sass', '~> 3.0'
  gem.add_development_dependency 'byebug'
  gem.add_development_dependency 'capybara', '~> 2.13'
  gem.add_dependency 'coffee-rails', '~> 4.2'
  gem.add_development_dependency 'coveralls'
  gem.add_dependency 'devise'
  gem.add_dependency 'devise-guests', '~> 0.6'
  gem.add_development_dependency 'factory_bot'
  gem.add_development_dependency 'fcrepo_wrapper'
  gem.add_development_dependency 'ffaker'
  gem.add_dependency 'font-awesome-rails'
  gem.add_dependency 'hydra-role-management'
  gem.add_dependency 'hyrax', '2.5.1'
  gem.add_development_dependency 'hyrax-spec'
  gem.add_dependency 'jbuilder', '~> 2.5'
  gem.add_dependency 'jquery-rails'
  gem.add_dependency 'listen', '>= 3.0.5', '< 3.2'
  gem.add_development_dependency 'puma', '~> 3.7'
  gem.add_dependency 'rake'
  gem.add_dependency 'riiif', '~> 2.0'
  gem.add_dependency 'rsolr', '>= 1.0'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-rails'
  gem.add_development_dependency 'rspec_junit_formatter'
  gem.add_dependency "sass-rails", "~> 5.0.4"
  gem.add_development_dependency 'selenium-webdriver'
  gem.add_dependency 'solr_wrapper', '>= 0.3'
  gem.add_development_dependency 'spring'
  gem.add_development_dependency 'spring-watcher-listen', '~> 2.0.0'
  gem.add_dependency 'sqlite3', '~> 1.3.0'
  gem.add_dependency 'turbolinks', '~> 5'
  gem.add_dependency 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
  gem.add_dependency 'uglifier', '>= 1.3.0'
  gem.add_development_dependency 'web-console', '>= 3.3.0'
  gem.add_development_dependency 'yard'
  gem.add_dependency 'font-awesome-sass', '~> 4.4.0'
  gem.add_dependency 'sidekiq'
end
