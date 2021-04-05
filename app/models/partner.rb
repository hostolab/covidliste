class Partner < ApplicationRecord
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable

  validates :name, presence: true
  validates :phone_number, presence: true
  validates :email, email: { mx: true, message: 'Email invalide' }

  encrypts :email
  encrypts :phone_number
  encrypts :name
  blind_index :email

  has_many :partner_vaccination_centers
  has_many :vaccination_centers, -> { where.not(confirmed_at: nil) }, through: :partner_vaccination_centers
  has_many :unconfirmed_vaccination_centers, -> { where(confirmed_at: nil) }, through: :partner_vaccination_centers, source: :vaccination_center

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  def confirmed?
    confirmed_at.present?
  end

  def full_name
    name
  end
end
