class AddIndexOnUserIdToSlotAlerts < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  def change
    add_index(:slot_alerts, [:user_id, :created_at], algorithm: :concurrently)
  end
end
