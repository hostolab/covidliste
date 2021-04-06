class CreateVaccinationCenters < ActiveRecord::Migration[6.1]
  def change
    create_table :vaccination_centers do |t|
      t.string :name
      t.string :description
      t.string :address
      t.float :lat
      t.float :lon
      t.string :kind
      t.boolean :pfizer
      t.boolean :moderna
      t.boolean :astrazeneca
      t.boolean :janssen
      t.date :confirmed_at
      t.string :phone_number
      t.references :partner, foreign_key: true

      t.timestamps
    end
  end
end
