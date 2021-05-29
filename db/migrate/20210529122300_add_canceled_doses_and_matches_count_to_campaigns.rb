class AddCanceledDosesAndMatchesCountToCampaigns < ActiveRecord::Migration[6.1]
  def change
    add_column :campaigns, :canceled_doses, :integer, default: 0, null: false
    add_column :campaigns, :matches_count, :integer, default: 0, null: false
    add_column :campaigns, :matches_confirmed_count, :integer, default: 0, null: false
  end
end
