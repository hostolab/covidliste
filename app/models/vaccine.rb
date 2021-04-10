class Vaccine < ApplicationRecord
  module Brands
    ASTRAZENECA = "astrazeneca"
    JANSSEN = "janssen"
    MODERNA = "moderna"
    PFIZER = "pfizer"

    ALL = [ASTRAZENECA, JANSSEN, MODERNA, PFIZER].freeze
  end

  def self.minimum_reach_to_dose_ratio(vaccine)
    case vaccine
    when Brands::ASTRAZENECA
      20
    else
      5
    end
  end

  def self.overbooking_factor(vaccine)
    case vaccine
    when Brands::ASTRAZENECA
      3
    else
      2
    end
  end
end
