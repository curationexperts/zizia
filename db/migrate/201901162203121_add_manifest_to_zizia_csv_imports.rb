# frozen_string_literal: true
class AddManifestToZiziaCsvImports < ActiveRecord::Migration[5.1]
  def change
    add_column :zizia_csv_imports, :manifest, :string
  end
end
