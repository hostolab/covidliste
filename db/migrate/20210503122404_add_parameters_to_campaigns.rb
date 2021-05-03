class AddParametersToCampaigns < ActiveRecord::Migration[6.1]
  def change
    add_column :campaigns, :parameters, :jsonb
  end
end
