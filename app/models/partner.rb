class Partner < ApplicationRecord
  include HasPhoneNumberConcern
  has_phone_number_types %i[mobile]

  devise :database_authenticatable,
    :recoverable,
    :rememberable,
    :validatable,
    :confirmable,
    :zxcvbnable

  validates :name, presence: true
  validates :phone_number, presence: true
  validates :email, email: {mx: true, message: "Email invalide"}

  encrypts :email
  encrypts :phone_number
  encrypts :name
  blind_index :email

  has_many :partner_vaccination_centers
  has_many :vaccination_centers, -> { where.not(confirmed_at: nil) }, through: :partner_vaccination_centers
  has_many :unconfirmed_vaccination_centers, lambda {
                                               where(confirmed_at: nil)
                                             }, through: :partner_vaccination_centers, source: :vaccination_center

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  def confirmed?
    confirmed_at.present?
  end

  def full_name
    name
  end

  def skip_password_complexity?
    !encrypted_password_changed?
  end
end
