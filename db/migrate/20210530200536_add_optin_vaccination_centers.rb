class AddOptinVaccinationCenters < ActiveRecord::Migration[6.1]
  def change
    add_column :vaccination_centers, :visible_optin_at, :datetime
    add_column :vaccination_centers, :media_optin_at, :datetime
  end
end
