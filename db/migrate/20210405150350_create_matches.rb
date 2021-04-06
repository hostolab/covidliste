class CreateMatches < ActiveRecord::Migration[6.1]
  def change
    create_table :matches do |t|
      t.references :vaccination_center, foreign_key: true
      t.references :campaign, foreign_key: true
      t.references :campaign_batch, foreign_key: true
      t.references :partner, foreign_key: true
      t.references :user, foreign_key: true
      t.datetime :sent_at
      t.datetime :expires_at
      t.datetime :confirmed_at
      t.text :token

      t.timestamps
    end
  end
end
