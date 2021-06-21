class AddConfirmedSmsSentAtToMatches < ActiveRecord::Migration[6.1]
  def change
    add_column :matches, :confirmed_sms_sent_at, :datetime
    add_column :matches, :conf_sms_provider, :string
    add_column :matches, :conf_sms_provider_id, :string
    add_column :matches, :conf_sms_status, :string
    add_index(:matches, [:conf_sms_provider, :conf_sms_provider_id])
  end
end
