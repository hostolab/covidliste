class AddTocToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :toc, :boolean
  end
end
