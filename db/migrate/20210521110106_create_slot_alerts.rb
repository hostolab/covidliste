class CreateSlotAlerts < ActiveRecord::Migration[6.1]
  def change
    create_table :slot_alerts do |t|
      t.integer :vmd_slot_id
      t.integer :user_id
      t.datetime :sent_at
      t.datetime :clicked_at
      t.datetime :refused_at
      t.jsonb :settings
      t.string :token
      t.string :token_ciphertext
      t.string :token_bidx
      t.timestamps
    end
    add_index :slot_alerts, :token, unique: true
    add_index :slot_alerts, :token_bidx, unique: true
  end
end
