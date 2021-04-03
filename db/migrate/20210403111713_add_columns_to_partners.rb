class AddColumnsToPartners < ActiveRecord::Migration[6.1]
  def change
    add_column :partners, :name, :string
  end
end
