class AddConfirmationTokenCiphertextToMatches < ActiveRecord::Migration[6.1]
  def up
    add_column :matches, :match_confirmation_token_ciphertext, :string
  end

  def down
    remove_column :matches, :match_confirmation_token_ciphertext
  end
end
