class MoveNameFieldsFromUsersToMatches < ActiveRecord::Migration[6.1]
  class Match < ApplicationRecord
  end

  class User < ApplicationRecord
    has_many :matches, class_name: "MoveNameFieldsFromUsersToMatches::Match"
  end

  def up
    add_column :matches, :firstname_ciphertext, :text
    add_column :matches, :lastname_ciphertext, :text

    if column_exists?(:users, :firstname_ciphertext) && column_exists?(:users, :lastname_ciphertext)
      Match.reset_column_information
      Object.send(:remove_const, "Match")
      User.find_each do |user|
        user.matches.update_all(
          firstname_ciphertext: user.firstname_ciphertext,
          lastname_ciphertext: user.lastname_ciphertext
        )
      end
    end
  end

  def down
    remove_column :matches, :firstname_ciphertext
    remove_column :matches, :lastname_ciphertext
  end
end
