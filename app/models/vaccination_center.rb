class VaccinationCenter < ApplicationRecord
  include HasPhoneNumberConcern
  has_phone_number_types %i[fixed_line mobile voip]
  module Kinds
    CABINET_INFIRMIER = "Cabinet infirmier"
    CABINET_MEDICAL = "Cabinet médical"
    CENTRE_VACCINATION = "Centre de vaccination"
    EHPAD = "Ehpad"
    HOPITAL = "Hôpital"
    PHARMACIE = "Pharmacie"

    ALL = [CABINET_INFIRMIER, CABINET_MEDICAL, CENTRE_VACCINATION, EHPAD, HOPITAL, PHARMACIE].freeze
  end

  include PgSearch::Model
  pg_search_scope :global_search, against: [:name, :description, :kind, :address]

  validates :name, :address, :phone_number, presence: true
  validates :lat, :lon, presence: true, on: :validation_by_admin
  validates :kind, inclusion: {in: VaccinationCenter::Kinds::ALL}
  validates :address, postal_address: {with_zipcode: true}, on: :create

  has_many :partner_vaccination_centers
  has_many :partners, through: :partner_vaccination_centers
  belongs_to :confirmer, class_name: "User", optional: true

  has_many :campaigns

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  after_initialize :approximated_lat_lon
  attr_reader :approximated_lat, :approximated_lon

  after_commit :push_to_slack, on: :create
  after_commit :geocode_address, if: -> { saved_change_to_address? }

  def active?
    confirmed? && !disabled?
  end

  def disabled?
    disabled_at.present?
  end

  def confirmed?
    confirmed_at.present?
  end

  def can_be_accessed_by?(user, partner)
    return true if user&.has_role?(:admin)

    partners.include?(partner)
  end

  def geocode_address
    GeocodeResourceJob.perform_now(self)
  end

  def self.to_csv
    headers = ["ID", "Nom du centre", "Type de centre", "Adresse", "Téléphone", "Type de vaccin", "Nom du contact", "Email du contact", "Téléphone du contact", "Validé", "Validé par", "Validé le"]

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
          vaccination_center.human_friendly_phone_number,
          vaccin_types,
          vaccination_center.partners&.first&.name,
          vaccination_center.partners&.first&.email,
          vaccination_center.partners&.first&.human_friendly_phone_number,
          confirmed
        ]
        if confirmed
          line += [vaccination_center.confirmer&.to_s, vaccination_center.confirmed_at].compact
        end
        csv << line
      end
    end
  end

  def flipper_id
    "#{self.class.name}_#{id}"
  end

  def build_campaign_smart_defaults
    last_campaign = campaigns.order(:created_at).last
    if last_campaign
      last_campaign_slice = last_campaign.as_json.slice("extra_info", "vaccine_type", "min_age", "max_age", "max_distance_in_meters", "available_doses")
      campaigns.build(last_campaign_slice)
    else
      campaigns.build
    end
  end

  def human_friendly_geo_area
    if zipcode && city && geo_context
      region = geo_context.split(",")[-1]
      "#{city}, #{region} (#{zipcode})"
    end
  end

  private

  def approximated_lat_lon
    return if lat.nil? || lon.nil?
    results = ::RandomizeCoordinatesService.new(lat, lon, 5000).call
    @approximated_lat = results[:lat]
    @approximated_lon = results[:lon]
  end

  def push_to_slack
    return unless Rails.env.production?

    # Wait for vaccination partner to be created
    PushNewVaccinationCenterToSlackJob.set(wait: 5.seconds).perform_later(id)
  end
end
