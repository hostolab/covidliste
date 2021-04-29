class AddStatementAcceptedAtToPartners < ActiveRecord::Migration[6.1]
  def change
    add_column :partners, :statement_accepted_at, :timestamp
  end
end
