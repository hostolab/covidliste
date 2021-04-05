class Partner < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :validatable,
         :registerable

  validates :name, presence: true

  has_many :partner_vaccination_centers
  has_many :vaccination_centers, -> { where.not(confirmed_at: nil) }, through: :partner_vaccination_centers
  has_many :vaccination_center_unconfirmed, -> { where(confirmed_at: nil) }, through: :partner_vaccination_center, source: :vaccination_center

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  def confirmed?
    confirmed_at.present?
  end
end
