class AddConfirmedMailSentAtToMatches < ActiveRecord::Migration[6.1]
  def change
    add_column :matches, :confirmed_mail_sent_at, :datetime
  end
end
