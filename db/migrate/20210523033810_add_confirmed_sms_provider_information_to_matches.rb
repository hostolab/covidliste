class AddConfirmedSmsProviderInformationToMatches < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    ActiveRecord::Base.transaction do
      add_column :matches, :conf_sms_provider, :string
      add_column :matches, :conf_sms_provider_id, :string
      add_index(:matches, [:conf_sms_provider, :conf_sms_provider_id])
    end
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :matches, :conf_sms_provider
      remove_column :matches, :conf_sms_provider_id
    end
  end
end
