class AddSourceToMatches < ActiveRecord::Migration[6.1]
  def up
    add_column :matches, :source, :string
  end

  def down
    remove_column :matches, :source
  end
end
