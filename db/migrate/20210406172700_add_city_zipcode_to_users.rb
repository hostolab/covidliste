class AddCityZipcodeToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :zipcode, :string
    add_column :users, :city, :string
    add_column :users, :geo_citycode, :string
    add_column :users, :geo_context, :string

    add_index :users, :zipcode
    add_index :users, :city
    add_index :users, :geo_citycode
    add_index :users, :geo_context
  end
end
