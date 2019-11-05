class AddUniquenessConstraintToPreIngestWorkDeduplicationKey < ActiveRecord::Migration[5.1]
  def change
    remove_index :zizia_pre_ingest_works, :deduplication_key if index_exists?(:zizia_pre_ingest_works, :deduplication_key)

    add_index :zizia_pre_ingest_works, :deduplication_key, unique: true
  end
end
