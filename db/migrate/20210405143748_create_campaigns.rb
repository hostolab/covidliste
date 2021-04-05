class CreateCampaigns < ActiveRecord::Migration[6.1]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.references :vaccination_center, foreign_key: true
      t.references :partner, foreign_key: true
      t.string :vaccine_type, null: false
      t.integer :available_doses, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :extra_info
      t.integer :min_age, null: false
      t.integer :max_distance_in_meters, null: false

      t.check_constraint('starts_at < ends_at', name: 'starts_at_lt_ends_at')
      t.check_constraint('available_doses > 0', name: 'available_doses_gt_zero')
      t.check_constraint('min_age > 0', name: 'min_age_gt_zero')
      t.check_constraint('max_distance_in_meters > 0', name: 'max_distance_in_meters_gt_zero')
      t.check_constraint("vaccine_type IN ('pfizer', 'moderna', 'astrazeneca', 'janssen')", name: 'vaccine_type_is_a_known_brand')

      t.timestamps
    end
  end
end
