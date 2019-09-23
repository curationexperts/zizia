class AddSuccessCountToCsvImportDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :zizia_csv_import_details, :success_count, :integer
  end
end
