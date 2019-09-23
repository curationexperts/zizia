class AddUpdateActorStackToCsvImportDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :zizia_csv_import_details, :update_actor_stack, :string
  end
end
