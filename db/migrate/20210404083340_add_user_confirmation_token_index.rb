class AddUserConfirmationTokenIndex < ActiveRecord::Migration[6.1]
  def change
    commit_db_transaction
    add_index :users, [:confirmation_token], algorithm: :concurrently
  end
end
