class CreatePartnerExternalAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :partner_external_accounts do |t|
      t.references :partner
      t.string :provider_id
      t.string :sub_bidx
      t.text :sub_ciphertext
      t.text :info_ciphertext
      t.timestamps
    end

    add_index(:partner_external_accounts, :sub_bidx)
    add_index(:partner_external_accounts, :provider_id)
    add_index(:partner_external_accounts, [:sub_bidx, :provider_id], unique: true)
  end
end
