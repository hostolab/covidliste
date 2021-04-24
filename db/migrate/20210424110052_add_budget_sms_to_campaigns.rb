class AddBudgetSmsToCampaigns < ActiveRecord::Migration[6.1]
  def up
    add_column :campaigns, :sms_max_count, :integer, null: false, default: 0
    add_column :campaigns, :sms_sent_count, :integer, null: false, default: 0
    add_check_constraint :campaigns, "sms_sent_count <= sms_max_count", name: "sms_sent_count_lt_eq_sms_max_count"
  end

  def down
    remove_check_constraint :campaigns, name: "sms_sent_count_lt_eq_sms_max_count"
    remove_column :campaigns, :sms_sent_count, :integer, null: false, default: 0
    remove_column :campaigns, :sms_max_count, :integer, null: false, default: 0
  end
end
