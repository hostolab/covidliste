class RemoveMatchConfirmationTokenFromMatches < ActiveRecord::Migration[6.1]
  
  def up
    remove_column :matches, :match_confirmation_token
    remove_index :matches, :match_confirmation_token if index_exists?(:matches, :match_confirmation_token)
  end

  def down
    add_column :matches, :match_confirmation_token, :string
    add_index :matches, :match_confirmation_token, unique: true
  end
end
