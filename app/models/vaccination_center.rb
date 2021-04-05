class VaccinationCenter < ApplicationRecord

  validates_presence_of :name, :description, :address, :lat, :lon, :phone_number
  validates :kind, inclusion: { in: VaccinationCenter::Kinds::ALL }

  has_many :partner_vaccination_center
  has_many :partner, through: :partner_vaccination_center
  belongs_to :confirmer, class_name: 'User', optional: true

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  module Kinds
    CENTRE_VACCINATION = 'Centre de vaccination'
    CABINET_MEDICAL = 'Cabinet médical'
    PHARMACIE = 'Pharmacie'
    EHPAD = 'Ehpad'

    ALL = [CENTRE_VACCINATION, CABINET_MEDICAL, PHARMACIE, EHPAD].freeze
  end

  def confirmed?
    confirmed_at.present?
  end
end
