class DropUsers < ActiveRecord::Migration[5.1]
  def change
    def up
      drop_table :users
    end

    def down
      fail ActiveRecord::IrreversibleMigration
    end
  end
end
