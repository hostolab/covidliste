class AddOptinPartner < ActiveRecord::Migration[6.1]
  def change
    add_column :partners, :visible_optin_at, :datetime
    add_column :partners, :media_optin_at, :datetime
    add_column :partners, :visible_optin, :boolean, default: false
    add_column :partners, :media_optin, :boolean, default: false
  end
end
