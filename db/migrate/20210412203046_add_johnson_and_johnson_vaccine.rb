class AddJohnsonAndJohnsonVaccine < ActiveRecord::Migration[6.1]
  def change
    add_column :vaccination_centers, :johnson_and_johnson, :boolean, default: false

    change_table :campaigns do |t|
      t.remove_check_constraint(name: "vaccine_type_is_a_known_brand")
      t.check_constraint("vaccine_type IN ('pfizer', 'moderna', 'astrazeneca', 'janssen', 'johnson_and_johnson')", name: "vaccine_type_is_a_known_brand")
    end
  end
end
