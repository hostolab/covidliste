class CreateVaccinationCenter < ActiveRecord::Migration[6.1]
  def change
    create_table :vaccination_centers do |t|
      t.string :name
      t.string :description
      t.string :type
      t.string :num_address
      t.string :voie_address
      t.string :postal
      t.string :city
      t.float :lat
      t.float :lon
      t.string :phone_number
      t.string :vaccins
      t.string :email
      t.string :confirmed_at

      t.timestamps
    end
  end
end
