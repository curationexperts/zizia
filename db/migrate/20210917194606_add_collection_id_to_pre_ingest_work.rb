class AddCollectionIdToPreIngestWork < ActiveRecord::Migration[5.2]
  def change
    add_column :zizia_pre_ingest_works, :collection_id, :string
  end
end
