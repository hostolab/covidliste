class VaccinationCenter < ApplicationRecord

  validates_presence_of :name, :description, :address, :lat, :lon, :phone_number
  validates :kind, inclusion: { in: ['Centre de vaccination', 'Cabinet médical', 'Pharmacie', 'Ephad'] }

  has_many :partner_vaccination_center
  has_many :partner, through: :partner_vaccination_center
  belongs_to :confirmer, class_name: 'User', optional: true

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  def confirmed?
    confirmed_at.present?
  end
end
