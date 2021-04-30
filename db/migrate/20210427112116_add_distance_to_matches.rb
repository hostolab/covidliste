class AddDistanceToMatches < ActiveRecord::Migration[6.1]
  def change
    add_column :matches, :distance_in_meters, :integer
  end
end
