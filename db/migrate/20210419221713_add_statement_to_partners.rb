class AddStatementToPartners < ActiveRecord::Migration[6.1]
  def change
    add_column :partners, :statement, :boolean, default: false
  end
end
