class AddUpdateActorStackToZiziaCsvImports < ActiveRecord::Migration[5.1]
  def change
    add_column :zizia_csv_imports, :update_actor_stack, :string
  end
end
