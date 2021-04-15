class AddDisableAtOnVaccinationCenter < ActiveRecord::Migration[6.1]
  def change
    add_column :vaccination_centers, :disabled_at, :timestamp
  end
end
