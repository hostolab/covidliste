class AddLockableToPartner < ActiveRecord::Migration[6.1]
  def change
    add_column :partners, :failed_attempts, :integer, default: 0, null: false # Only if lock strategy is :failed_attempts
    add_column :partners, :locked_at, :datetime

    # Add these only if unlock strategy is :email or :both
    add_column :partners, :unlock_token, :string
    add_index :partners, :unlock_token, unique: true
  end
end
