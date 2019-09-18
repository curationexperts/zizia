# frozen_string_literal: true

FactoryBot.define do
  factory :collection, aliases: [:public_collection] do
    sequence(:title) { |n| ["Test Collection Title #{n}"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    collection_type { Hyrax::CollectionType.find_or_create_default_collection_type }
  end

  factory :private_collection, parent: :collection do
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
  end
end
