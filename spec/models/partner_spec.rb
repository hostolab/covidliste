require "rails_helper"

RSpec.describe Partner, type: :model do
  describe "Full name" do
    it "should return name" do
      partner = Partner.new(name: "Pharmacie de Marseille")
      expect(partner.full_name).to eq("Pharmacie de Marseille")
    end
  end

  describe "to_s" do
    it "should return name" do
      partner = Partner.new(name: "Pharmacie de Marseille")
      expect(partner.to_s).to eq("Pharmacie de Marseille")
    end
  end
end
