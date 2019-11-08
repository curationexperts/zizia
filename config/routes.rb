# frozen_string_literal: true
Zizia::Engine.routes.draw do
  post 'csv_imports/preview', as: 'preview_csv_import'
  get 'csv_imports/preview', to: redirect('csv_imports/new')
  resources :csv_imports, only: [:index, :show, :new, :create]

  get 'importer_documentation/guide', to: 'metadata_details#show'
  get 'importer_documentation/profile', to: 'metadata_details#profile'
  get 'importer_documentation/csv', to: 'importer_documentation#csv'

  get 'csv_import_details/index'
  get 'csv_import_details/show/:id', to: 'csv_import_details#show', as: 'csv_import_detail'
  get 'pre_ingest_works/thumbnails/:deduplication_key', to: 'pre_ingest_works#thumbnails'
end
