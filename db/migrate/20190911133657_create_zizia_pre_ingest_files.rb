class CreateZiziaPreIngestFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :zizia_pre_ingest_files do |t|
      t.integer :size
      t.text :row
      t.integer :row_number
      t.string :filename
      t.belongs_to :pre_ingest_work
      t.timestamps
    end
  end
end
