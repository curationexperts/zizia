# Zizia

<table width="100%">
<tr><td>
<img alt="Zizia image" src="https://camo.githubusercontent.com/87eafa4a5b6a84802eab583e532bb33881b8a7ab/68747470733a2f2f7777772e706572766572646f6e6b2e636f6d2f77696c64253230666c6f776572732f506172736e69702f476f6c64656e253230416c6578616e646572732f323030383038253230476f6c64656e253230416c6578616e646572253230285a697a69612532306175726561292532302d2532304e47532532302d253230746865253230426f6f6b2532306f6625323057696c64253230466c6f776572732e6a7067" width="500px">
</td><td>

Object import for Hyrax. See the <a href="https://www.rubydoc.info/gems/zizia">API documentation</a> for more
information. See the <a href="https://curationexperts.github.io/zizia/">Getting Started</a> guide for a gentle introduction.
<br/><br/>


[![Gem Version](https://badge.fury.io/rb/zizia.svg)](https://badge.fury.io/rb/zizia)
[![CircleCI](https://circleci.com/gh/curationexperts/zizia.svg?style=svg)](https://circleci.com/gh/curationexperts/zizia)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/zizia) [![Coverage Status](https://coveralls.io/repos/github/curationexperts/zizia/badge.svg?branch=master)](https://coveralls.io/github/curationexperts/zizia?branch=master)

</td></tr>
</table>

## Usage

In your project's `Gemfile`, add: `gem 'zizia'`, then run `bundle install`.

To do a basic Hyrax import, first ensure that a [work type is registered](http://www.rubydoc.info/github/samvera/hyrax/Hyrax/Configuration#register_curation_concern-instance_method)
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

## Customizing
To input any kind of file other than CSV, you need to provide a `Parser` (out of the box, we support simple CSV import with `CsvParser`). We will be writing guides about
how to support custom mappers (for metadata outside of Hyrax's core and basic metadata fields).

## Hyrax User Interface

Zizia can be installed as a Rails Engine in a Hyrax application. To use the Zizia UI in Hyrax:

1. Add the engine to `routes.rb`:
```
  mount Zizia::Engine => '/'
```

2. Add the helpers to the `ApplicationController`

```
helper Zizia::Engine.helpers
```

3. Give admin users permission to import in your `Ability.custom_permissions`:

```
    can :manage, Zizia::CsvImport if current_user.admin?
```

4. Add links to `/csv_imports/new` and `/importer_documentation/csv` in the Hyrax dashboard

The `spec/dummy` folder in this application is a complete Hyrax application with Zizia installed. 
You can use that as an example for adding this to your current Hyrax application or copy that
to create a new application with Zizia installed. 


## Development

```sh
git clone https://github.com/curationexperts/zizia
cd zizia

bundle install
bundle exec rake ci
```

### RSpec Support

This gem ships with RSpec shared examples and other support tools intended to ease testing and ensure
interoperability of client code. These can be included by adding `require 'zizia/spec'` to a
`spec_helper.rb` or `rails_helper.rb` file in your application's test suite.
