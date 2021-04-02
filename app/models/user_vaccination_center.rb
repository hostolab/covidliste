class UserVaccinationCenter < ApplicationRecord
  belongs_to :user
  belongs_to :vaccination_center
end
