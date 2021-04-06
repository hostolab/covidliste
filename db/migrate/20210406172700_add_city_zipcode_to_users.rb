class AddCityZipcodeToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :zipcode, :string
    add_column :users, :city, :string
  end
end
