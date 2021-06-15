class AddMatchesCountToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  def change
    add_column :users, :matches_count, :integer, default: 0
    add_index(:users, :matches_count, algorithm: :concurrently)
  end
end
