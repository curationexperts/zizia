class AddDeduplicationFieldToCsvImportDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :zizia_csv_import_details, :deduplication_field, :string
  end
end
