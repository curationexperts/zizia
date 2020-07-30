# Zizia

<table width="100%">
<tr><td>
<img alt="Zizia image" src="https://camo.githubusercontent.com/87eafa4a5b6a84802eab583e532bb33881b8a7ab/68747470733a2f2f7777772e706572766572646f6e6b2e636f6d2f77696c64253230666c6f776572732f506172736e69702f476f6c64656e253230416c6578616e646572732f323030383038253230476f6c64656e253230416c6578616e646572253230285a697a69612532306175726561292532302d2532304e47532532302d253230746865253230426f6f6b2532306f6625323057696c64253230466c6f776572732e6a7067"?
</td><td width="50%">

Object import for Hyrax.

[![Gem Version](https://badge.fury.io/rb/zizia.svg)](https://badge.fury.io/rb/zizia)
[![CircleCI](https://circleci.com/gh/curationexperts/zizia.svg?style=svg)](https://circleci.com/gh/curationexperts/zizia)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/zizia) [![Coverage Status](https://coveralls.io/repos/github/curationexperts/zizia/badge.svg?branch=master)](https://coveralls.io/github/curationexperts/zizia?branch=master)

</td></tr>
</table>

## Usage

In your project's `Gemfile`, add: `gem 'zizia'`, then run `bundle install`.
1. Require 'zizia' in your `config/application.rb` file:

```
module MyApplication
  class Application < Rails::Application
    require 'zizia'
```

2. Add the engine to `routes.rb`:
```
  mount Zizia::Engine => '/'
```

3. Add the helpers to the `ApplicationController`

```
helper Zizia::Engine.helpers
```

4. Give admin users permission to import in your `Ability.custom_permissions`:

```
    can :manage, Zizia::CsvImport if current_user.admin?
    can :manage, Zizia::CsvImportDetail if current_user.admin?
```

5. Add links to `/csv_imports/new` and `/importer_documentation/csv` in the Hyrax dashboard.

6. In your Rails application's `application.css` and `application.js` include Zizia's assets:

```
 *= require zizia/application
```

7. Run `rake db:migrate`

The `spec/dummy` folder in this application is a complete Hyrax application with Zizia installed.
You can use that as an example for adding this to your current Hyrax application or copy that
to create a new application with Zizia installed.

8. Add a deduplication_key to your default work type's metadata:

```
  property :deduplication_key, predicate: ::RDF::Vocab::BF2::identifiedBy, multiple: false do |index|
    index.as :stored_searchable
  end
```

9. If you are using the default [Hyrax metadata profile](https://samvera.github.io/metadata_application_profile.html) aka `Hyrax::BasicMetadata`, you are ready to download a sample CSV and start importing.


If you aren't using `Hyrax::BasicMetadata` you'll need to create a custom `importer` and `mapper` class. First ensure that a [work type is registered](http://www.rubydoc.info/github/samvera/hyrax/Hyrax/Configuration#register_curation_concern-instance_method)
with your `Hyrax` application. Then write a class like this:

```ruby
require 'zizia'

class MyImporter
  def initialize(csv_file)
    @csv_file = csv_file
    raise "Cannot find expected input file #{csv_file}" unless File.exist?(csv_file)
  end

  def import
    attrs = {
      collection_id: collection_id,     # pass a collection id to the record importer and all records will be added to that collection
      depositor_id: depositor_id,       # pass a Hyrax user_key here and that Hyrax user will own all objects created during this import
      deduplication_field: 'identifier' # pass a field with a persistent identifier (e.g., ARK) and it will check to see if a record with that identifier already
    }                                   # exists, update its metadata if so, and only if it doesn't find a record with that identifier will it make a new object.

    file = File.open(@csv_file)
    parser = Zizia::CsvParser.new(file: file)
    record_importer = Zizia::HyraxRecordImporter.new(attributes: attrs)
    Zizia::Importer.new(parser: parser, record_importer: record_importer).import
    file.close # unless a block is passed to File.open, the file must be explicitly closed
  end
end
```

You can find [an example csv file for import to Hyrax](https://github.com/curationexperts/zizia/blob/master/spec/fixtures/hyrax/example.csv) in the fixtures directory. Files for attachment should have the filename in a column
with a heading of `files`, and the location of the files should be specified via an
environment variables called `IMPORT_PATH`. If `IMPORT_PATH` is not set, `HyraxRecordImporter` will look in `/opt/data` by default.

## Local Development

```sh
git clone https://github.com/curationexperts/zizia
cd zizia

bundle install
```

To run Solr and Fedora for testing purposes, open a new terminal session for each and run the following commands:

`solr_wrapper --config spec/dummy/config/solr_wrapper_test.yml`
`fcrepo_wrapper --config spec/dummy/config/fcrepo_wrapper_test.yml`

After this you can run the whole suite:
```bash
bundle exec rspec spec
```

System specs are located in the `spec/dummy/spec/system` folder:

`bundle exec rspec spec/dummy/spec/system/csv_import_details_page_spec.rb`


## Customizing
To input any kind of file other than CSV, you need to provide a `Parser` (out of the box, we support simple CSV import with `CsvParser`). We will be writing guides about
how to support custom mappers (for metadata outside of Hyrax's core and basic metadata fields).

## Releasing

To make a new release:
1. Increase the version number in `lib/zizia/version.rb`
1. Increase the same version number in `.github_changelog_generator`
1. Update CHANGELOG.md by running this command:
  ```ruby
  github_changelog_generator --user curationexperts --project zizia --token YOUR_GITHUB_TOKEN_HERE
  ```
1. Commit these changes to the master branch
1. Run `rake release`
