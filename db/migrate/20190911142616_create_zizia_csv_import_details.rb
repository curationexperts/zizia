class CreateZiziaCsvImportDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :zizia_csv_import_details do |t|
      t.belongs_to :csv_import
      t.timestamps
    end
  end
end
