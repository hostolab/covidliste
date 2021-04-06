class VaccinationCenter < ApplicationRecord
  module Kinds
    CENTRE_VACCINATION = "Centre de vaccination"
    CABINET_MEDICAL = "Cabinet médical"
    PHARMACIE = "Pharmacie"
    EHPAD = "Ehpad"

    ALL = [CENTRE_VACCINATION, CABINET_MEDICAL, PHARMACIE, EHPAD].freeze
  end

  validates_presence_of :name, :address, :lat, :lon, :phone_number
  validates :kind, inclusion: {in: VaccinationCenter::Kinds::ALL}

  has_many :partner_vaccination_centers
  has_many :partners, through: :partner_vaccination_centers
  belongs_to :confirmer, class_name: "User", optional: true

  has_many :campaigns

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  after_commit :push_to_slack, on: :create

  def confirmed?
    confirmed_at.present?
  end

  def can_be_accessed_by?(user, partner)
    return true if user&.admin?

    partners.include?(partner)
  end

  private

  def push_to_slack
    return unless Rails.env.production?

    # Wait for vaccination partner to be created
    PushNewVaccinationCenterToSlackJob.set(wait: 5.seconds).perform_later(self)
  end
end
