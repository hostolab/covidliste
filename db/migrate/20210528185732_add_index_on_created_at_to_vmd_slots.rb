class AddIndexOnCreatedAtToVmdSlots < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  def change
    add_index(:vmd_slots, :created_at, algorithm: :concurrently)
  end
end
