class CampaignBatch < ApplicationRecord
  belongs_to :vaccination_center
  belongs_to :partner
  belongs_to :campaign
end
