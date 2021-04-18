class User < ApplicationRecord
  include HasPhoneNumberConcern
  has_phone_number_types %i[mobile]
  rolify

  devise :database_authenticatable,
    :recoverable,
    :rememberable,
    :validatable,
    :confirmable

  has_many :matches, dependent: :nullify

  encrypts :firstname
  encrypts :lastname
  encrypts :address
  encrypts :phone_number
  encrypts :email

  blind_index :email
  geocoded_by :address, latitude: :lat, longitude: :lon

  validates :password, presence: true, on: :create
  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :address, presence: true
  validates :birthdate, presence: true
  validates :toc, presence: true, acceptance: true
  validates :statement, presence: true, acceptance: true, unless: proc { |u| u.reset_password_token.present? }
  validates :email,
    email: {
      mx: true,
      message: "Email invalide"
    },
    format: {
      without: /gmail\.fr|gamil\.com|gmil\.com|gmaul\.com|gamail\.com|gmai\.com|gmail\.cm|hormail\.com|hotmal\.com|hormail\.fr/i,
      message: "Email invalide"
    },
    if: :email_changed?
  validate :password_complexity

  after_commit :geocode_address, if: -> { saved_change_to_address? && anonymized_at.nil? }
  before_save :approximate_coords

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :between_age, ->(min, max) { where("birthdate between ? and ?", max.years.ago, min.years.ago) }
  scope :with_roles, -> { joins(:roles) }

  PASSWORD_REGEX = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{#{Devise.password_length.min},#{Devise.password_length.max}}$"
  PASSWORD_HINT = "#{Devise.password_length.min} caractères minimum avec au moins 1 chiffre, au moins 1 caractère spécial, au moins 1 lettre minuscule et au moins 1 lettre majuscule."
  LATLNG_DECIMALS = 3

  def approximate_coords
    return if lat.nil? || lon.nil?

    self.lat = lat.round(LATLNG_DECIMALS)
    self.lon = lon.round(LATLNG_DECIMALS)
  end

  def geocode_address
    GeocodeResourceJob.perform_later(self)
  end

  def full_name
    anonymized_at.nil? ? "#{firstname} #{lastname}" : "Anonymous"
  end

  def distance(lat, lon)
    Geocoder::Calculations.distance_between([lat, lon], [self.lat, self.lon]).round(1)
  end

  def age
    now = Time.now.utc.to_date
    now.year - birthdate.year - (now.month > birthdate.month || (now.month == birthdate.month && now.day >= birthdate.day) ? 0 : 1)
  end

  def confirmed?
    confirmed_at.present?
  end

  def super_admin?
    has_role?(:super_admin)
  end

  def admin?
    has_role?(:admin) || super_admin?
  end

  def anonymize!
    return unless anonymized_at.nil?

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
    self.anonymized_at = Time.now.utc
    save(validate: false)
  end

  def to_csv
    columns = %w[created_at updated_at email firstname lastname birthdate phone_number address lat lon zipcode city geo_citycode geo_context]
    CSV.generate(headers: true) do |csv|
      csv << columns
      csv << columns.map { |column| send(column) }
    end
  end

  def password_complexity
    return if password.nil? || password =~ /#{User::PASSWORD_REGEX}/o
    errors.add :password, "pas assez robuste. #{User::PASSWORD_HINT}."
  end

  protected

  # Devise override
  def password_required?
    confirmed? ? super : false
  end
end
