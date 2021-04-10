class MatchStatsColumns < ActiveRecord::Migration[6.1]
  def change
    add_column :matches, :age, :integer
    add_column :matches, :zipcode, :string
    add_column :matches, :city, :string
    add_column :matches, :geo_citycode, :string
    add_column :matches, :geo_context, :string
  end
end
