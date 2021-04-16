class MatchAddRefuseAtCol < ActiveRecord::Migration[6.1]
  def change
    add_column :matches, :refused_at, :timestamp
  end
end
