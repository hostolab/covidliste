class RemoveEmailFromUsersTake2 < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :email, :string
  end
end
