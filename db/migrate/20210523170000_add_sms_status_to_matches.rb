class AddSmsStatusToMatches < ActiveRecord::Migration[6.1]
  def up
    add_column :matches, :sms_status, :string
  end
end
