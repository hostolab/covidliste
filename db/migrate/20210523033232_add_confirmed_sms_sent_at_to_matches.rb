class AddConfirmedSmsSentAtToMatches < ActiveRecord::Migration[6.1]
  def change
    add_column :matches, :confirmed_sms_sent_at, :datetime
  end
end
