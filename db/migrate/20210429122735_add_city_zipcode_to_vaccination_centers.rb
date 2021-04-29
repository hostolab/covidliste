class AddCityZipcodeToVaccinationCenters < ActiveRecord::Migration[6.1]
  def change
    add_column :vaccination_centers, :zipcode, :string
    add_column :vaccination_centers, :city, :string
    add_column :vaccination_centers, :geo_citycode, :string
    add_column :vaccination_centers, :geo_context, :string

    add_index :vaccination_centers, :zipcode
    add_index :vaccination_centers, :city
    add_index :vaccination_centers, :geo_citycode
    add_index :vaccination_centers, :geo_context
  end
end
