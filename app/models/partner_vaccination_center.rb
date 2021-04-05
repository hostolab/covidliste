class PartnerVaccinationCenter < ApplicationRecord
  belongs_to :partner
  belongs_to :vaccination_center
end
