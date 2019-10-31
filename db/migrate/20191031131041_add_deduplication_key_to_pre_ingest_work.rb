class AddDeduplicationKeyToPreIngestWork < ActiveRecord::Migration[5.1]
  def change
    add_column :zizia_pre_ingest_works, :deduplication_key, :string
    add_index :zizia_pre_ingest_works, :deduplication_key
  end
end
