class VaccinationCenter < ApplicationRecord
  validates_presence_of :name, :description, :address, :lat, :lon, :phone_number
  validates :kind, inclusion: { in: ['Centre de vaccination', 'Cabinet médical', 'Pharmacie', 'Ephad'] }

  has_many :partner_vaccination_centers
  has_many :partners, through: :partner_vaccination_centers
  belongs_to :confirmer, class_name: 'User', optional: true

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  after_commit :push_to_slack, on: :create

  def confirmed?
    confirmed_at.present?
  end

  private

  def push_to_slack
    return unless Rails.env.production?

    PushNewVaccinationCenterToSlack.new(self).call
  end
end
