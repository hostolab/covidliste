class AddConfirmedSmsProviderInformationToMatches < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    ActiveRecord::Base.transaction do
      add_column :matches, :conf_sms_provider, :string
      add_column :matches, :conf_sms_provider_id, :string
      add_index(:matches, [:conf_sms_provider, :conf_sms_provider_id])
    end

    # We need to split backfilling into batches to avoid locking up the entire table in one transaction.
    # Code inspired from https://wework.github.io/data/2015/11/05/add-columns-with-default-values-to-large-tables-in-rails-postgres/
    return unless Match.last
    last_id = Match.last.id
    batch_size = 10000
    (0..last_id).step(batch_size).each do |from_id|
      to_id = from_id + batch_size
      ActiveRecord::Base.transaction do
        execute <<-SQL
          UPDATE matches
            SET
              conf_sms_provider = 'twilio'
            WHERE (id BETWEEN #{from_id} AND #{to_id}) AND confirmed_sms_sent_at IS NOT NULL
        SQL
      end
    end
  rescue => e
    # Rollback
    down
    raise e
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :matches, :conf_sms_provider
      remove_column :matches, :conf_sms_provider_id
    end
  end
end
