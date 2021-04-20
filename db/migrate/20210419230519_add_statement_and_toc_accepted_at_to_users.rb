class AddStatementAndTocAcceptedAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :statement_accepted_at, :timestamp
    add_column :users, :toc_accepted_at, :timestamp
  end
end
