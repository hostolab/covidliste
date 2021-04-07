class RemoveTokenFromMatches < ActiveRecord::Migration[6.1]
  def change
    remove_column :matches, :token
  end
end
