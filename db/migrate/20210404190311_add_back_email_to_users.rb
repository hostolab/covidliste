class AddBackEmailToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :email, :string
  end
end
