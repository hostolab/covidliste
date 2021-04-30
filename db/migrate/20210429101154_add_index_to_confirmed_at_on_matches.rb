class AddIndexToConfirmedAtOnMatches < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  def change
    add_index(:matches, :confirmed_at, algorithm: :concurrently) if table_exists?(:matches)
  end
end
