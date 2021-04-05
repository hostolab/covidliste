class VaccinationCenter < ApplicationRecord
  belongs_to :partner, optional: true

  validates_presence_of :name, :description, :address, :lat, :lon, :kind, :phone_number
end
