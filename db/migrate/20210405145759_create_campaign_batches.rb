class CreateCampaignBatches < ActiveRecord::Migration[6.1]
  def change
    create_table :campaign_batches do |t|
      t.references :campaign, foreign_key: true
      t.references :vaccination_center, foreign_key: true
      t.references :partner, foreign_key: true
      t.timestamp :expires_at, null: false
      t.integer :size, null: false, default: 0

      t.check_constraint('size > 0', name: 'size_gt_or_eq_zero')

      t.timestamps
    end
  end
end
