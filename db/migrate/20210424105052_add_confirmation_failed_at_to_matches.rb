class AddConfirmationFailedAtToMatches < ActiveRecord::Migration[6.1]
  def change
    add_column :matches, :confirmation_failed_at, :datetime
  end
end
