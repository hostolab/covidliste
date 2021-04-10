class AddAnonymousToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :anonymized_at, :datetime
  end
end
