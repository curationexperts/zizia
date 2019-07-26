# frozen_string_literal: true
Zizia::Engine.routes.draw do
  get 'importer_documentation/guide'
  get 'importer_documentation/csv'

  post 'csv_imports/preview', as: 'preview_csv_import'
  get 'csv_imports/preview', to: redirect('csv_imports/new')
  resources :csv_imports, only: [:index, :show, :new, :create]
end
