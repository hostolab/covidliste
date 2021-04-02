class CreateUserVaccinationCenter < ActiveRecord::Migration[6.1]
  def change
    create_table :user_vaccination_centers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :vaccination_center, null: false, foreign_key: true

      t.timestamps
    end
  end
end
