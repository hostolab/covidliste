class User < ApplicationRecord
  extend Memoist
  include HasPhoneNumberConcern
  has_phone_number_types %i[mobile]
  rolify

  attr_accessor :address, :skip_reverse_geocode

  devise :magic_link_authenticatable, :confirmable, :validatable

  has_many :matches, dependent: :nullify
  has_many :messages, class_name: "Ahoy::Message", as: :user
  has_many :slot_alerts

  encrypts :firstname
  encrypts :lastname
  encrypts :phone_number
  encrypts :email

  blind_index :email

  validates :address, presence: true, postal_address: {with_zipcode: true}, on: :create
  validates :lat, presence: true, unless: proc { |u| u.persisted? }
  validates :lon, presence: true, unless: proc { |u| u.persisted? }
  validates :birthdate, presence: true
  validates :toc, presence: true, acceptance: true
  validates :statement, presence: true, acceptance: true
  validates :email,
    'valid_email_2/email': {
      mx: true,
      message: "Email invalide"
    },
    format: {
      without: /gmail\.fr|gamil\.com|gmil\.com|gmaul\.com|gamail\.com|gmai\.com|gmail\.cm|hormail\.com|hotmal\.com|hormail\.fr/i,
      message: "Email invalide"
    },
    if: :email_changed?

  before_save :extract_email_domain, if: -> { will_save_change_to_email? }
  before_save :randomize_lat_lon, if: -> { (will_save_change_to_lat? || will_save_change_to_lon?) }
  before_save :get_grid_cell, if: -> { (will_save_change_to_lat? || will_save_change_to_lon?) }
  after_commit :reverse_geocode, if: -> { (saved_change_to_lat? || saved_change_to_lon?) && anonymized_at.nil? }, unless: :skip_reverse_geocode

  before_destroy :refuse_pending_matching, prepend: true
  after_create_commit :increment_total_users_counter

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :active, -> { where(anonymized_at: nil, match_confirmed_at: nil) }
  scope :between_age, ->(min, max) { where(birthdate: max.years.ago..min.years.ago) }
  scope :with_roles, -> { joins(:roles) }

  PASSWORD_HINT = "Le mot de passe choisi doit être robuste ou très robuste pour pouvoir compléter votre inscription. Il doit notamment comporter au moins 8 caractères avec un mélange de chiffres et de lettres."

  ANONYMIZED_REASONS = {
    covidliste: "J'ai trouvé un rendez-vous grâce à Covidliste",
    not_interested: "Je ne suis plus intéressé",
    other: "Autre"
  }.freeze

  ALERTING_INTENISITIES = {
    "1": "1 fois par jour",
    "2": "Moins de 3 fois par jour",
    "3": "Toutes les alertes"
  }.freeze

  def randomize_lat_lon
    return if lat.nil? || lon.nil?
    results = ::RandomizeCoordinatesService.new(lat, lon).call
    self.lat = results[:lat]
    self.lon = results[:lon]
  end

  def extract_email_domain
    self.email_domain = begin
      Digest::SHA256.hexdigest(Mail::Address.new(email).domain)
    rescue
      nil
    end
  end

  def get_grid_cell
    return if lat.nil? || lon.nil?
    cell = ::GridCoordsService.new(lat, lon).get_cell
    self.grid_i = cell[:i]
    self.grid_j = cell[:j]
  end

  def ensure_lat_lon
    return unless lat.nil? || lon.nil?
    return if address.blank?
    results = GeocodingService.new(address).call

    if results.present?
      self.lat = results[:lat]
      self.lon = results[:lon]
    end
  end

  def reverse_geocode
    ReverseGeocodeResourceJob.perform_later(self)
  end

  def full_name
    if anonymized_at.nil?
      "#{firstname} #{lastname}"
    else
      "Anonymous"
    end
  end

  def to_s
    if anonymized_at.nil?
      if missing_identity?
        email
      else
        full_name
      end
    else
      "Anonymous"
    end
  end

  def age
    return unless birthdate
    now = Time.now.utc.to_date
    now.year - birthdate.year - (now.month > birthdate.month || (now.month == birthdate.month && now.day >= birthdate.day) ? 0 : 1)
  end

  def confirmed?
    confirmed_at.present?
  end

  def missing_identity?
    firstname.blank? || lastname.blank?
  end

  def has_role?(role_name, resource = nil)
    if role_name == :volunteer
      roles = Rails.application.config.x.covidliste["admin_roles"].keys
      roles.any? { |role| has_role?(role) }
    else
      role_config = Rails.application.config.x.covidliste["admin_roles"].fetch(role_name)
      parent_role = role_config[:parent_role]
      if parent_role.nil? || (role_name == parent_role)
        super(:"#{role_name}", resource)
      else
        super(:"#{role_name}", resource) || has_role?(:"#{parent_role}")
      end
    end
  end
  memoize :has_role?

  def anonymize!(reason = nil)
    return unless anonymized_at.nil?
    refuse_pending_matching

    self.email = "anonymous#{id}+#{rand(100_000_000)}@null"
    self.firstname = nil
    self.lastname = nil
    self.address = nil
    self.lat = nil
    self.lon = nil
    self.zipcode = nil
    self.city = nil
    self.geo_citycode = nil
    self.geo_context = nil
    self.phone_number = nil
    self.birthdate = nil
    self.grid_i = nil
    self.grid_j = nil
    self.last_inactive_user_email_sent_at = nil
    self.anonymized_at = Time.now.utc
    self.anonymized_reason = reason
    save(validate: false)
  end

  def to_csv
    columns = %w[created_at updated_at email firstname lastname birthdate phone_number address lat lon zipcode city geo_citycode geo_context]
    CSV.generate(headers: true) do |csv|
      csv << columns
      csv << columns.map { |column| public_send(column) }
    end
  end

  # Enables to only validate specific attributes of the model
  def valid_attributes?(*attributes)
    attributes.each do |attribute|
      self.class.validators_on(attribute).each do |validator|
        validator.validate_each(self, attribute, send(attribute))
      end
    end
    errors.none?
  end

  def increment_total_users_counter
    Counter.increment(:total_users)
  end

  def flipper_id
    "#{self.class.name}_#{id}"
  end

  def send_slot_alert!
    best_slot = VmdSlot.find_slots_for_user(id).first
    return unless best_slot
    SlotAlert.create!(vmd_slot: best_slot, user_id: id)
  end

  def find_confirmed_match
    matches.confirmed.first
  end

  def find_available_matches
    matches.pending.includes([:campaign]).order(id: :asc)
  end

  def find_available_match
    find_available_matches.each do |match|
      if match.confirmable? && !match.expired?
        return match
      end
    end
    nil
  end

  def find_confirmed_or_available_match
    confirmed_match = find_confirmed_match
    return confirmed_match if confirmed_match
    find_available_match
  end

  def find_or_create_match
    existing_match = find_confirmed_or_available_match
    return existing_match if existing_match

    campaigns = ::ReachableUsersService.get_running_campaigns_for_user(self)
    return if campaigns.blank?
    campaign = campaigns.first
    return if campaign.blank?
    return unless campaign.running?
    return if campaign.remaining_doses <= 0
    return if Time.now.utc >= campaign.ends_at

    @match = Match.find_by(campaign_id: campaign.id, user_id: id)
    if @match.blank?
      REDIS_LOCK.lock!("create_match_for_user_id_#{id}", 2000) do
        @match = Match.create(
          campaign: campaign,
          vaccination_center: campaign.vaccination_center,
          user: self
        )
        return if @match.present? && @match.errors.present?
        return @match
      rescue Redlock::LockError
        Rails.logger.warn("Could not obtain lock to create match for user_id #{id}")
      end
    end
    nil
  end

  protected

  def skip_password_complexity?
    true unless encrypted_password_changed?
  end

  private

  def refuse_pending_matching
    matches.pending.map(&:refuse!)
  end
end
