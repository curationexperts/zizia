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
  gem.add_dependency 'rails', '~> 5.1.7'
  gem.add_dependency 'carrierwave'
  gem.add_dependency 'redcarpet'

  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'bixby'
  gem.add_development_dependency 'hyrax', '~> 2.5'
  gem.add_development_dependency 'hyrax-spec'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-rails'
  gem.add_development_dependency 'rspec_junit_formatter'
  gem.add_development_dependency 'coveralls'
  gem.add_development_dependency 'solr_wrapper',   '~> 2.1'
  gem.add_development_dependency 'fcrepo_wrapper', '~> 0.9'
  gem.add_development_dependency 'byebug'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'sqlite3'


  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
end
