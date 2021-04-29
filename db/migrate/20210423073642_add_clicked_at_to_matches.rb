class AddClickedAtToMatches < ActiveRecord::Migration[6.1]
  def up
    add_column :matches, :email_first_clicked_at, :datetime
    add_column :matches, :sms_first_clicked_at, :datetime
  end

  def down
    remove_column :matches, :email_first_clicked_at
    remove_column :matches, :sms_first_clicked_at
  end
end
