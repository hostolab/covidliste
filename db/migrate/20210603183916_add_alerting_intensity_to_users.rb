class AddAlertingIntensityToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  def change
    add_column :users, :alerting_intensity, :integer, default: 1
    add_index(:users, :alerting_intensity, algorithm: :concurrently)
  end
end
