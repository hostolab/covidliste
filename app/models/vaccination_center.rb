class VaccinationCenter < ApplicationRecord
  has_many :user_vaccination_centers
  has_many :users, through: :user_vaccination_centers

  validates :name, presence: true
  validates :description, presence: true
  validates :type, presence: true
  validates :num_address, presence: true
  validates :voie_address, presence: true
  validates :postal, presence: true
  validates :city, presence: true
  validates :lat, presence: true
  validates :lon, presence: true
  validates :phone_number, presence: true
  validates :email, presence: true

  def address
    "#{num_address} #{voie_address} #{postal} #{city}"
  end

end
