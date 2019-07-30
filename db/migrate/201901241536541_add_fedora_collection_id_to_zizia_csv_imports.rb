class AddFedoraCollectionIdToZiziaCsvImports < ActiveRecord::Migration[5.1]
  def change
    add_column :zizia_csv_imports, :fedora_collection_id, :string
  end
end
