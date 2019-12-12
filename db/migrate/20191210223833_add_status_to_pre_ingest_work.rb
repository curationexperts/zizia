class AddStatusToPreIngestWork < ActiveRecord::Migration[5.1]
  def change
    add_column :zizia_pre_ingest_works, :status, :string, default: 'preingest'
  end
end
