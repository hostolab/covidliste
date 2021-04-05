class Match < ApplicationRecord
  belongs_to :vaccination_center
  belongs_to :campaign
  belongs_to :campaign_batch
  belongs_to :partner
  belongs_to :user
end
