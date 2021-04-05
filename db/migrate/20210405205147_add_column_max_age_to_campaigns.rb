class AddColumnMaxAgeToCampaigns < ActiveRecord::Migration[6.1]
  def change
    add_column :campaigns, :max_age, :integer

    add_check_constraint(:campaigns, 'max_age > 0 AND max_age > min_age', name: 'max_age_gt_zero')
  end
end
