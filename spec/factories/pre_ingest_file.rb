# frozen_string_literal: true
# This will guess the User class
FactoryBot.define do
  factory :pre_ingest_file, class: Zizia::PreIngestFile do
    pre_ingest_work_id { 1 }
    created_at { Time.current }
    updated_at { Time.current }
    row_number { 1 }
    row { 'sample,row' }
    filename { '/a/path/to/my.csv' }
    size { 100_203_424 }
  end
end
