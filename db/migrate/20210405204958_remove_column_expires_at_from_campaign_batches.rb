class RemoveColumnExpiresAtFromCampaignBatches < ActiveRecord::Migration[6.1]
  def up
    remove_column :campaign_batches, :expires_at
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
