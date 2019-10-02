# frozen_string_literal: true
# This will guess the User class
FactoryBot.define do
  factory :csv_import, class: Zizia::CsvImport do
    id { 1 }
    user_id { 1 }
    created_at { Time.current }
    updated_at { Time.current }
    manifest { Rails.root.join('spec', 'fixtures', 'csv_imports', 'good', 'all_fields.csv') }
    fedora_collection_id { '1' }
    update_actor_stack { 'HyraxDefault' }
  end
end
