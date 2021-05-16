class AddPhoneNumberToCampaign < ActiveRecord::Migration[6.1]
  def change
    add_column :campaigns, :phone_number, :string
  end
end
