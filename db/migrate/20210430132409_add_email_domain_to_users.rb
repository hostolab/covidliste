class AddEmailDomainToUsers < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :email_domain, :string
  end

  def down
    remove_column :users, :email_domain
  end
end
