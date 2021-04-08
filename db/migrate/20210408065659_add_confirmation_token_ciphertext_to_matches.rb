class AddConfirmationTokenCiphertextToMatches < ActiveRecord::Migration[6.1]
  def up
    add_column :matches, :match_confirmation_token_ciphertext, :string
    add_column :matches, :match_confirmation_token_bidx, :string
    add_index :matches, :match_confirmation_token_bidx, unique: true
  end

  def down
    remove_column :matches, :match_confirmation_token_ciphertext
    remove_column :matches, :match_confirmation_token_bidx
    remove_index :matches, column: :match_confirmation_token_bidx if index_exists?(:matches, :match_confirmation_token_bidx)
  end
end
