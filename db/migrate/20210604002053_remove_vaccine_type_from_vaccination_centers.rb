class RemoveVaccineTypeFromVaccinationCenters < ActiveRecord::Migration[6.1]
  def change
    add_column :vaccination_centers, :finess, :string
    remove_column :vaccination_centers, :astrazeneca
    remove_column :vaccination_centers, :pfizer
    remove_column :vaccination_centers, :moderna
    remove_column :vaccination_centers, :janssen
  end
end
