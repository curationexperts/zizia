class AddBatchIdToCsvImportDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :zizia_csv_import_details, :batch_id, :string
  end
end
