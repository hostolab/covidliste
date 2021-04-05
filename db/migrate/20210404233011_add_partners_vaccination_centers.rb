class AddPartnersVaccinationCenters < ActiveRecord::Migration[6.1]
  def change
    create_table(:partner_vaccination_centers) do |t|
      t.references :partner, foreign_key: true
      t.references :vaccination_center, foreign_key: true

      t.timestamps
    end

    add_index(:partner_vaccination_centers, [ :partner_id, :vaccination_center_id ], name: 'idx_partners_vac_centers_on_partner_id_and_vac_center_id')

    remove_column :vaccination_centers, :partner_id, :bigint
    add_reference :vaccination_centers, :confirmer, foreign_key: { to_table: :users }
  end
end

