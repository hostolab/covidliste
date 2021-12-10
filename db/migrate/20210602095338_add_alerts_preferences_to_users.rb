class AddAlertsPreferencesToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  def change
    add_column :users, :max_distance_km, :integer, default: 10
    add_column :users, :alerting_optin_at, :datetime
    add_index(:users, :alerting_optin_at, algorithm: :concurrently)
  end
end
