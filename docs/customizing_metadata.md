# Customizing metadata import

Often the data you will want to import will not conform exactly to the fields you get from `Hyrax::BasicMetadata`, in which case you will need to make a custom mapper.

Again, let's start with making a test. Make a file called `spec/importers/custom_mapper.rb`. Let's start by describing the CSV we expect to import:

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomMapper do
  subject(:mapper) { described_class.new }

  let(:metadata) do
    { "Name.architect" => "Imhotep", # architect
      "Type.genre" => "Journalism" # genre
    }

    describe '#fields' do
    it 'has expected fields' do
      expect(mapper.fields).to include(
        :architect,
        :genre
      )
    end
  end
```
From this rspec test, I can conclude that I have two customized metadata fields, `architect` and `genre`. Actually adding custom metadata fields is covered elsewhere (See [this guide](https://samvera.github.io/customize-metadata-generate-work-type.html), for example), so here we are just going to assume that these fields exist already, and are defined as multi-valued strings.


* Put a file in `config/initializers/zizia.rb`

It should look like this:

```ruby
Zizia.config do |config|
  config.metadata_mapper_class = CustomMapper
  config.default_info_stream = Rails.logger
  config.default_error_stream = Rails.logger
end
```
This tells zizia what class to use for metadata mappings, and where to log the output.
