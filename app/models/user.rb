class User < ApplicationRecord
  extend Memoist
  include HasPhoneNumberConcern
  has_phone_number_types %i[mobile]
  rolify

  attr_accessor :address

  devise :magic_link_authenticatable, :confirmable, :validatable

  has_many :matches, dependent: :nullify
  has_many :messages, class_name: "Ahoy::Message", as: :user

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
  after_commit :reverse_geocode, if: -> { (saved_change_to_lat? || saved_change_to_lon?) && anonymized_at.nil? }
  before_destroy :refuse_pending_matching, prepend: true
  after_create_commit :increment_total_users_counter

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :active, -> { where(anonymized_at: nil) }
  scope :between_age, ->(min, max) { where(birthdate: max.years.ago..min.years.ago) }
  scope :with_roles, -> { joins(:roles) }

  PASSWORD_HINT = "Le mot de passe choisi doit être robuste ou très robuste pour pouvoir compléter votre inscription. Il doit notamment comporter au moins 8 caractères avec un mélange de chiffres et de lettres."

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

  def anonymize!
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
    self.anonymized_at = Time.now.utc
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

  protected

  def skip_password_complexity?
    true unless encrypted_password_changed?
  end

  private

  def refuse_pending_matching
    matches.pending.map(&:refuse!)
  end
end
