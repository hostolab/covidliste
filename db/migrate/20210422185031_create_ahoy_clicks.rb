class CreateAhoyClicks < ActiveRecord::Migration[6.1]
  def change
    create_table :ahoy_clicks do |t|
      t.string :campaign, index: true
      t.string :token
    end

    add_column :ahoy_messages, :campaign, :string
    add_index :ahoy_messages, :campaign
  end
end
