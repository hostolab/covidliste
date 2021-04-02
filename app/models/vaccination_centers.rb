class VaccinationCenters < ApplicationRecord
  has_and_belongs_to_many :users, :join_table => :vaccination_centers

  validates :name, presence: true
  validates :num_address, presence: true
  validates :voie_address, presence: true
  validates :postal, presence: true
  validates :city, presence: true
  validates :lat, presence: true
  validates :long, presence: true
  validates :phone_number, presence: true

end