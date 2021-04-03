class RemoveUnencryptedUserColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :firstname, :string
    remove_column :users, :lastname, :string
    remove_column :users, :address, :string
    remove_column :users, :phone_number, :string
  end
end
