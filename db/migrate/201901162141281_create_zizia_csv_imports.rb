# frozen_string_literal: true
class CreateZiziaCsvImports < ActiveRecord::Migration[5.1]
  def change
    create_table :zizia_csv_imports do |t|
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
