class UpdateMatchSentAt < ActiveRecord::Migration[6.1]
  def change
    rename_column :matches, :sent_at, :sms_sent_at
    add_column :matches, :mail_sent_at, :datetime
  end
end
