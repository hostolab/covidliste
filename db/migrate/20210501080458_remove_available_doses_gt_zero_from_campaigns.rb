class RemoveAvailableDosesGtZeroFromCampaigns < ActiveRecord::Migration[6.1]
  def change
    remove_check_constraint :campaigns, name: 'available_doses_gt_zero'
    add_check_constraint :campaigns, "available_doses >= 0 AND available_doses <= 1000", name: 'available_doses_gt_zero'
  end
end
