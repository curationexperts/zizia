class AddStatusToPreIngestFile < ActiveRecord::Migration[5.1]
  def change
    add_column :zizia_pre_ingest_files, :status, :string, default: 'preingest'
  end
end
