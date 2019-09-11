class CreateZiziaPreIngestWorks < ActiveRecord::Migration[5.1]
  def change
    create_table :zizia_pre_ingest_works do |t|
      t.integer :parent_object
      t.belongs_to :csv_import_detail
      t.timestamps
    end
  end
end
