require "rails_helper"

RSpec.describe Match, type: :model do
  describe "#confirm!" do
    it "should copy User information at confirmation" do
      user = create(:user,
        birthdate: Date.today - 60.years,
        zipcode: "75001",
        city: "Paris",
        geo_citycode: "75001",
        geo_context: "GEO_CONTEXT"
      )

      match = create(:match, user: user)
      match.confirm!
      expect(match.age).to eq 60
      expect(match.zipcode).to eq "75001"
      expect(match.city).to eq "Paris"
      expect(match.geo_citycode).to eq "75001"
      expect(match.geo_context).to eq "GEO_CONTEXT"
    end
  end
end
