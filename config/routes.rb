# frozen_string_literal: true
Zizia::Engine.routes.draw do
  post 'csv_imports/preview', as: 'preview_csv_import'
  get 'csv_imports/preview', to: redirect('csv_imports/new')
  resources :csv_imports, only: [:index, :show, :new, :create]

  get 'importer_documentation/guide', to: 'metadata_details#show'
  get 'importer_documentation/profile', to: 'metadata_details#profile'
end
