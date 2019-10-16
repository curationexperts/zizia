# coding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe Zizia::HyraxBasicMetadataMapper do
  let(:mapper) { described_class.new }

  # Properties defined in Hyrax::CoreMetadata
  let(:core_fields) do
    [:title]
  end

  # Properties defined in Hyrax::BasicMetadata
  let(:basic_fields) do
    [:resource_type, :creator, :contributor,
     :description, :keyword, :license,
     :rights_statement, :publisher, :date_created,
     :subject, :language, :identifier, :based_near,
     :related_url, :bibliographic_citation, :source]
  end

  let(:tenejo_fields) do
    [:visibility, :files]
  end

  it_behaves_like 'a Zizia::Mapper' do
    let(:metadata) do
      { title: ['A Title for a Record'],
        my_custom_field: ['This gets ignored'] }
    end
    let(:expected_fields) { core_fields + basic_fields + tenejo_fields }
  end

  context 'with metadata, but some missing fields' do
    before { mapper.metadata = metadata }
    let(:metadata) do
      { 'title' => 'A Title',
        'language' => 'English' }
    end

    it 'provides methods for the fields, even fields that aren\'t included in the metadata' do
      expect(metadata).to include('title')
      expect(mapper).to respond_to(:title)

      expect(metadata).not_to include('source')
      expect(mapper).to respond_to(:source)
    end

    it 'returns single values for single-value fields' do
      expect(mapper.visibility).to eq 'restricted'
    end

    it 'returns array values for multi-value fields' do
      expect(mapper.title).to eq ['A Title']
      expect(mapper.language).to eq ['English']
      expect(mapper.keyword).to eq []
      expect(mapper.subject).to eq []
    end
  end

  context 'fields with multiple values' do
    before { mapper.metadata = metadata }
    let(:metadata) do
      { 'title' => 'A Title',
        'language' => 'English|~|French|~|Japanese' }
    end

    it 'splits the values using the delimiter' do
      expect(mapper.title).to eq ['A Title']
      expect(mapper.language).to eq ['English', 'French', 'Japanese']
      expect(mapper.keyword).to eq []
    end

    it 'can set a different delimiter' do
      expect(mapper.delimiter).to eq '|~|'
      mapper.delimiter = 'ಠ_ಠ'
      expect(mapper.delimiter).to eq 'ಠ_ಠ'
    end
  end

  describe 'lenient headers' do
    context 'headers with capital letters' do
      before { mapper.metadata = metadata }
      let(:metadata) do
        { 'Title' => 'A Title',
          'Related URL' => 'http://example.com',
          'Abstract or Summary' => 'desc1|~|desc2',
          'visiBILITY' => 'open' }
      end

      it 'matches the correct fields' do
        expect(mapper.title).to eq ['A Title']
        expect(mapper.related_url).to eq ['http://example.com']
        expect(mapper.description).to eq ['desc1', 'desc2']
        expect(mapper.creator).to eq []
        expect(mapper.visibility).to eq 'open'
      end
    end

    context 'headers with sloppy whitespace' do
      before { mapper.metadata = metadata }
      let(:metadata) do
        { ' Title ' => 'A Title',
          " Related URL \n " => 'http://example.com',
          ' visiBILITY ' => 'open' }
      end

      it 'matches the correct fields' do
        expect(mapper.title).to eq ['A Title']
        expect(mapper.related_url).to eq ['http://example.com']
        expect(mapper.visibility).to eq 'open'
      end
    end

    context 'Visibility values in the CSV should match the Edit UI' do
      load File.expand_path("../../../support/shared_contexts/with_work_type.rb", __FILE__)
      include_context 'with a work type'
      context 'public is a synonym for open' do
        before { mapper.metadata = metadata }
        let(:metadata) do
          { ' Title ' => 'A Title',
            " Related URL \n " => 'http://example.com',
            ' visiBILITY ' => 'PubLIC' }
        end

        it 'transforms public to open regardless of capitalization' do
          expect(mapper.title).to eq ['A Title']
          expect(mapper.related_url).to eq ['http://example.com']
          expect(mapper.visibility).to eq 'open'
        end
      end
      context 'institution name is a synonym for authenticated' do
        before { mapper.metadata = metadata }
        let(:metadata) do
          { ' Title ' => 'A Title',
            " Related URL \n " => 'http://example.com',
            ' visiBILITY ' => 'my_institution' }
        end

        it 'transforms institution name to authenticated regardless of capitalization' do
          expect(mapper.title).to eq ['A Title']
          expect(mapper.related_url).to eq ['http://example.com']
          expect(mapper.visibility).to eq 'authenticated'
        end
      end
      context 'full institution name is a synonym for authenticated' do
        before { mapper.metadata = metadata }
        let(:metadata) do
          { ' Title ' => 'A Title',
            " Related URL \n " => 'http://example.com',
            ' visiBILITY ' => 'my full institution name' }
        end

        it 'transforms full institution name to authenticated regardless of capitalization' do
          expect(mapper.title).to eq ['A Title']
          expect(mapper.related_url).to eq ['http://example.com']
          expect(mapper.visibility).to eq 'authenticated'
        end
      end
    end

    # When someone accidentally has too many commas in the CSV rows
    context 'headers with a nil' do
      before { mapper.metadata = metadata }
      let(:metadata) do
        { ' Title ' => 'A Title',
          nil => nil }
      end

      it 'doesn\'t raise an error for missing fields' do
        expect(mapper.source).to eq []
      end
    end
  end
end
