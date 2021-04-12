# frozen_string_literal: true

require "rails_helper"

RSpec.describe Vaccine, type: :model do
  describe "::minimum_reach_to_dose_ratio" do
    it "returns 20 for ASTRAZENECA" do
      expect(Vaccine.minimum_reach_to_dose_ratio(Vaccine::Brands::ASTRAZENECA)).to eq 20
    end

    it "returns 5 for JANSSEN" do
      expect(Vaccine.minimum_reach_to_dose_ratio(Vaccine::Brands::JANSSEN)).to eq 5
    end

    it "returns 5 for PFIZER" do
      expect(Vaccine.minimum_reach_to_dose_ratio(Vaccine::Brands::PFIZER)).to eq 5
    end

    it "returns 5 for JANSSEN" do
      expect(Vaccine.minimum_reach_to_dose_ratio(Vaccine::Brands::JANSSEN)).to eq 5
    end

    it "returns 5 for other" do
      expect(Vaccine.minimum_reach_to_dose_ratio("other")).to eq 5
    end
  end

  describe "::overbooking_factor" do
    it "returns 3 for ASTRAZENECA" do
      expect(Vaccine.overbooking_factor(Vaccine::Brands::ASTRAZENECA)).to eq 3
    end

    it "returns 2 for JANSSEN" do
      expect(Vaccine.overbooking_factor(Vaccine::Brands::JANSSEN)).to eq 2
    end

    it "returns 2 for PFIZER" do
      expect(Vaccine.overbooking_factor(Vaccine::Brands::PFIZER)).to eq 2
    end

    it "returns 2 for JANSSEN" do
      expect(Vaccine.overbooking_factor(Vaccine::Brands::JANSSEN)).to eq 2
    end

    it "returns 2 for other" do
      expect(Vaccine.overbooking_factor("other")).to eq 2
    end
  end
end
