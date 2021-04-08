class AddStatusToCampaign < ActiveRecord::Migration[6.1]
  def change
    add_column :campaigns, :status, :string, default: "En cours"
  end
end
