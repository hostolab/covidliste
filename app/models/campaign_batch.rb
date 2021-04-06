class CampaignBatch < ApplicationRecord
  belongs_to :vaccination_center
  belongs_to :partner, optional: true
  belongs_to :campaign
end
