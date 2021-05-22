class AddFollowUpSentAtToSlotAlerts < ActiveRecord::Migration[6.1]
  def change
    add_column :slot_alerts, :follow_up_sent_at, :datetime
  end
end
