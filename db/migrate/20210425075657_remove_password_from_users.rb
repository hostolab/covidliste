class RemovePasswordFromUsers < ActiveRecord::Migration[6.1]
  def up
    remove_column :users, :encrypted_password
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
  end

  def down
    add_column :users, :encrypted_password, :string, null: false, default: ""
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
  end
end
