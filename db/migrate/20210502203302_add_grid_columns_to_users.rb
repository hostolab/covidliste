class AddGridColumnsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :grid_i, :int
    add_column :users, :grid_j, :int
    add_index :users, :grid_i
    add_index :users, :grid_j
  end
end
