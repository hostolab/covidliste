class CreateCampaignBatches < ActiveRecord::Migration[6.1]
  def change
    create_table :campaign_batches do |t|
      t.references :campaign, foreign_key: true
      t.references :vaccination_center, foreign_key: true
      t.references :partner, foreign_key: true
      t.timestamp :expires_at, null: false
      t.integer :size, null: false
      t.integer :duration_in_minutes, null: false, default: 10

      t.check_constraint('size > 0', name: 'size_gt_zero')
      t.check_constraint('duration_in_minutes > 0', name: 'duration_in_minutes_gt_zero')

      t.timestamps
    end
  end
end
