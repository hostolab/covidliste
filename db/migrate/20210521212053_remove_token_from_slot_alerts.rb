class RemoveTokenFromSlotAlerts < ActiveRecord::Migration[6.1]
  def change
    remove_column :slot_alerts, :token
    remove_index :slot_alerts, :token if index_exists?(:slot_alerts, :token)
  end
end
