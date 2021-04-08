class AddStatusToCampaign < ActiveRecord::Migration[6.1]
  def change
    add_column :campaigns, :status, :integer, default: 0
    add_index :campaigns, :status
  end
end
