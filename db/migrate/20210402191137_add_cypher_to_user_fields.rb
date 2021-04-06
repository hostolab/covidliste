class AddCypherToUserFields < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :firstname_ciphertext, :text
    add_column :users, :lastname_ciphertext, :text
    add_column :users, :phone_number_ciphertext, :text
    add_column :users, :address_ciphertext, :text
  end
end
