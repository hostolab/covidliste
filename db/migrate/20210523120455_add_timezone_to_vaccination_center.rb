class AddTimezoneToVaccinationCenter < ActiveRecord::Migration[6.1]
  def change
    add_column :vaccination_centers, :timezone, :string, null: false, default: "Europe/Paris"
  end
end
