class MatchAddRefusedCol < ActiveRecord::Migration[6.1]
  def change
    add_column :matches, :refused, :boolean, default: false
  end
end
