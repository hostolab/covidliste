class Vaccine < ApplicationRecord
  module Brands
    ASTRAZENECA = "astrazeneca"
    JANSSEN = "janssen"
    MODERNA = "moderna"
    PFIZER = "pfizer"

    ALL = [ASTRAZENECA, JANSSEN, MODERNA, PFIZER].freeze
  end

  def self.minimum_reach_to_dose_ratio(vaccine)
    5
  end

  def self.overbooking_factor(vaccine)
    4
  end
end
