class PartnerConfirmable < ActiveRecord::Migration[6.1]
  def change
    change_table :partners do |t|
      t.string   :phone_number_ciphertext
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
    end


    rename_column :partners, :name, :name_ciphertext
    rename_column :partners, :email, :email_ciphertext

    add_column :partners, :email, :string
    add_column :partners, :email_bidx, :string
    add_index :partners, :email_bidx, unique: true

    change_column :vaccination_centers, :confirmed_at, :datetime

    add_index :partners, :confirmation_token, unique: true
  end
end
