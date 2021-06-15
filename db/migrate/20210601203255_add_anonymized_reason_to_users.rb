class AddAnonymizedReasonToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :anonymized_reason, :string
  end
end
