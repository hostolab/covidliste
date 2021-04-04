class AddEmailCipherTextToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :email_ciphertext, :text
  end
end
