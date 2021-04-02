class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable,
         :rememberable, 
         :validatable,
         :confirmable

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :address, presence: true
  validates :birthdate, presence: true
  validates :toc, presence: true, acceptance: true

  before_save :approximate_coords
  before_save :geocode_address, if: :will_save_change_to_address?

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  LATLNG_DECIMALS = 2

  def approximate_coords
    return if (self.lat.nil? || self.lon.nil?)
    self.lat = self.lat.round(LATLNG_DECIMALS)
    self.lon = self.lon.round(LATLNG_DECIMALS)
  end

  def geocode_address
    GeocodeJob.perform_later(id)
  end

  def full_name
    "#{firstname} #{lastname}"
  end

  def confirmed?
    confirmed_at.present?
  end

  def super_admin?
    has_role?(:super_admin)
  end

  def admin?
    has_role?(:admin)
  end

  protected

  # Devise override
  def password_required?
    confirmed? ? super : false
  end

end
