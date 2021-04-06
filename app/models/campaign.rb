class Campaign < ApplicationRecord
  belongs_to :vaccination_center
  belongs_to :partner
end
