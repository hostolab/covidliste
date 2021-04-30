class AddAlgoVersionToCampaigns < ActiveRecord::Migration[6.1]
  def up
    add_column :campaigns, :algo_version, :string
  end

  def down
    remove_column :campaigns, :algo_version
  end
end
