class ChangeUsersColumnName < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :lat, :latitude
    rename_column :users, :lon, :longitude
  end
end
