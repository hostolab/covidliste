class Campaign < ApplicationRecord
  belongs_to :vaccination_center
  belongs_to :partner
  has_many :campaign_batches
  has_many :matches
end
