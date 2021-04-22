class RemoveAddressFromUsers < ActiveRecord::Migration[6.1]
  def up
    remove_column :users, :address_ciphertext
  end

  def down
    add_column :users, :address_ciphertext, :string
  end
end
