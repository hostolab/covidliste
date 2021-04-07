class VaccinationCenter < ApplicationRecord
  module Kinds
    CABINET_MEDICAL = "Cabinet médical"
    CENTRE_VACCINATION = "Centre de vaccination"
    EHPAD = "Ehpad"
    HOPITAL = "Hôpital"
    PHARMACIE = "Pharmacie"

    ALL = [CABINET_MEDICAL, CENTRE_VACCINATION, EHPAD, HOPITAL, PHARMACIE].freeze
  end

  validates_presence_of :name, :address, :lat, :lon, :phone_number
  validates :kind, inclusion: {in: VaccinationCenter::Kinds::ALL}

  has_many :partner_vaccination_centers
  has_many :partners, through: :partner_vaccination_centers
  belongs_to :confirmer, class_name: "User", optional: true

  has_many :campaigns

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  after_commit :push_to_slack, on: :create

  def self.search(search)
    return VaccinationCenter.all unless search

    search = search.strip
    VaccinationCenter.distinct.where("name ILIKE ? OR description ILIKE ? OR address ILIKE ? OR phone_number ILIKE ?", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search.delete(" ")}%")
  end

  def confirmed?
    confirmed_at.present?
  end

  def can_be_accessed_by?(user, partner)
    return true if user&.admin?

    partners.include?(partner)
  end

  def self.to_csv
    headers = ["ID", "Nom du centre", "Type de centre", "Adresse", "Téléphone", "Type de vaccin", "Nom du contact", "Email du contact", "Validé", "Validé par", "Validé le"]

    CSV.generate("\uFEFF", headers: true) do |csv|
      csv << headers

      all.each do |vaccination_center|
        vaccin_types = ""
        confirmed = false
        if vaccination_center.pfizer
          vaccin_types += Vaccine::Brands::PFIZER + " "
        end
        if vaccination_center.moderna
          vaccin_types += Vaccine::Brands::MODERNA + " "
        end
        if vaccination_center.astrazeneca
          vaccin_types += Vaccine::Brands::ASTRAZENECA + " "
        end
        if vaccination_center.janssen
          vaccin_types += Vaccine::Brands::JANSSEN
        end
        if vaccination_center.confirmed_at
          confirmed = true
        end
        line = [
          vaccination_center.id,
          vaccination_center.name,
          vaccination_center.kind,
          vaccination_center.address,
          vaccination_center.phone_number,
          vaccin_types,
          vaccination_center.partners&.first&.name,
          vaccination_center.partners&.first&.email,
          confirmed
        ]
        if confirmed
          line += [vaccination_center.confirmer&.full_name, vaccination_center.confirmed_at]
        end
        csv << line
      end
    end
  end

  private

  def push_to_slack
    return unless Rails.env.production?

    # Wait for vaccination partner to be created
    PushNewVaccinationCenterToSlackJob.set(wait: 5.seconds).perform_later(self)
  end
end
