# frozen_string_literal: true
# This will guess the User class
FactoryBot.define do
  factory :pre_ingest_work, class: Zizia::PreIngestWork do
    id { 1 }
    created_at { Time.current }
    updated_at { Time.current }
    csv_import_detail_id { 1 }
    sequence(:deduplication_key) { |n| "zyx321cba#{n}" }
  end
end
