class AddOptionVaccinationCenters < ActiveRecord::Migration[6.1]
  def change
    add_column :vaccination_centers, :visible_option, :boolean, default: false
    add_column :vaccination_centers, :media_option, :boolean, default: false
    add_column :vaccination_centers, :visible_option_at, :datetime
    add_column :vaccination_centers, :media_option_at, :datetime
  end
end
