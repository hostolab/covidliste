class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :firstname
      t.string :lastname
      t.string :email
      t.date :birthdate
      t.string :address
      t.float :lat
      t.float :lon
      t.string :phone_number

      t.timestamps
    end
  end
end
