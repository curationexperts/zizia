class AddStatusToCsvImportDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :zizia_csv_import_details, :status, :string
  end
end
