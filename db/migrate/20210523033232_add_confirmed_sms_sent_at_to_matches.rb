class AddConfirmedSmsSentAtToMatches < ActiveRecord::Migration[6.1]
  def change
    add_column :slot_alerts, :confirmed_sms_sent_at, :datetime
  end
end
