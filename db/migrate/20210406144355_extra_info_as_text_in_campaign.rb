class ExtraInfoAsTextInCampaign < ActiveRecord::Migration[6.1]
  def change
    change_column :campaigns, :extra_info, :text
  end
end
