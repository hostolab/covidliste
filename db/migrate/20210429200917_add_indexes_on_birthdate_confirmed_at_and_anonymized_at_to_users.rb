class AddIndexesOnBirthdateConfirmedAtAndAnonymizedAtToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :users, :confirmed_at, algorithm: :concurrently
    add_index :users, :anonymized_at, algorithm: :concurrently
    add_index :users, :birthdate, algorithm: :concurrently
  end
end
