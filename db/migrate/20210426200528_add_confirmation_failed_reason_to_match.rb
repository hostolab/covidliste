class AddConfirmationFailedReasonToMatch < ActiveRecord::Migration[6.1]
  def change
    add_column :matches, :confirmation_failed_reason, :string, default: "", null: false
    add_index :matches, :confirmation_failed_reason
  end
end
