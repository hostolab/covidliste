class CreateVmdSlots < ActiveRecord::Migration[6.1]
  def change
    create_table :vmd_slots do |t|
      t.string :center_id
      t.string :name
      t.string :url
      t.float :latitude
      t.float :longitude
      t.string :city
      t.string :department
      t.string :address
      t.string :phone_number
      t.datetime :next_rdv
      t.string :platform
      t.string :center_type
      t.integer :slots_count
      t.datetime :last_updated_at
      t.integer :slots_0_days
      t.integer :slots_1_days
      t.integer :slots_2_days
      t.integer :slots_7_days
      t.integer :slots_28_days
      t.integer :slots_49_days
      t.boolean :astrazenca
      t.boolean :pfizer
      t.boolean :moderna
      t.boolean :janssen

      t.timestamps
    end

    add_index(:vmd_slots, :center_id)
    add_index(:vmd_slots, :department)
    add_index(:vmd_slots, [:center_id, :last_updated_at])
  end
end
