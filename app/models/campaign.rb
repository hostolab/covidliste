class Campaign < ApplicationRecord
  belongs_to :vaccination_center
  belongs_to :partner
  has_many :campaign_batches
  has_many :matches

  validates :available_doses, numericality: { greater_than: 0 }
  validates :vaccine_type, presence: true
end
