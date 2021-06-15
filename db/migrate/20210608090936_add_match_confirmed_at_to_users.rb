class AddMatchConfirmedAtToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  def change
    add_column :users, :match_confirmed_at, :datetime
    add_index(:users, :match_confirmed_at, algorithm: :concurrently)
  end
end
