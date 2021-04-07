class Vaccine < ApplicationRecord
  module Brands
    ASTRAZENECA = "astrazeneca"
    JANSSEN = "janssen"
    MODERNA = "moderna"
    PFIZER = "pfizer"

    ALL = [ASTRAZENECA, JANSSEN, MODERNA, PFIZER].freeze
  end
end
