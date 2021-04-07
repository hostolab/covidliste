class AddMatchConfirmationTokenToMatches < ActiveRecord::Migration[6.1]
  def change
    add_column :matches, :match_confirmation_token, :string
    add_index :matches, :match_confirmation_token, unique: true
  end
end
