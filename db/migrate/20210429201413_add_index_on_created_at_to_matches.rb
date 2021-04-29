class AddIndexOnCreatedAtToMatches < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :matches, :created_at, algorithm: :concurrently
  end

end

