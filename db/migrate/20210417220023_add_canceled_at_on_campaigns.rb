class AddCanceledAtOnCampaigns < ActiveRecord::Migration[6.1]
  def change
    add_column :campaigns, :canceled_at, :datetime
  end
end
