class User < ApplicationRecord
  include HasPhoneNumberConcern
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

  after_commit :geocode_address, if: :saved_change_to_address?
  before_save :approximate_coords

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :between_age, ->(min, max) { where("birthdate between ? and ?", max.years.ago, min.years.ago) }

  has_many :matches

  LATLNG_DECIMALS = 3

  def approximate_coords
    return if lat.nil? || lon.nil?

    self.lat = lat.round(LATLNG_DECIMALS)
    self.lon = lon.round(LATLNG_DECIMALS)
  end

  def geocode_address
    GeocodeUserJob.perform_later(id)
  end

  def full_name
    "#{firstname} #{lastname}"
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

  protected

  # Devise override
  def password_required?
    confirmed? ? super : false
  end
end
