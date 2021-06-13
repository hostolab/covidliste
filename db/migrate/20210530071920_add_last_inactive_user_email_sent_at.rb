class AddLastInactiveUserEmailSentAt < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :last_inactive_user_email_sent_at, :datetime
  end
end
