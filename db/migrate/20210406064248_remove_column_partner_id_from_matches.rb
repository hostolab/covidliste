class RemoveColumnPartnerIdFromMatches < ActiveRecord::Migration[6.1]
  def up
    remove_column :matches, :partner_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
