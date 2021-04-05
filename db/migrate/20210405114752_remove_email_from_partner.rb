class RemoveEmailFromPartner < ActiveRecord::Migration[6.1]
  def change
    remove_column :partners, :email
  end
end
