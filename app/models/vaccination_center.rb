class VaccinationCenter < ApplicationRecord
  has_many :users, :join_table => :vaccination_centers

  validates :name, presence: true
  validates :num_address, presence: true
  validates :voie_address, presence: true
  validates :postal, presence: true
  validates :city, presence: true
  validates :lat, presence: true
  validates :long, presence: true
  validates :phone_number, presence: true

  def address
    "#{num_address} #{voie_address} #{postal} #{city}"
  end

  
end