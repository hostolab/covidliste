require "rails_helper"

def get_lat_lng_for_number(xtile, ytile, zoom)
  n = 2.0 ** zoom
  lon_deg = xtile / n * 360.0 - 180.0
  lat_rad = Math::atan(Math::sinh(Math::PI * (1 - 2 * ytile / n)))
  lat_deg = 180.0 * (lat_rad / Math::PI)
  {:lat => lat_deg, :lon => lon_deg}
end

DEFAULT_ZOOM_LEVEL = 15

RSpec.describe ReachableUsersService, type: :service do
  let!(:vaccination_center) { create(:vaccination_center, lat: 42, lon: 2) }
  let!(:campaign) { build(:campaign, vaccination_center: vaccination_center, max_distance_in_meters: 5000, min_age: 18, max_age: 130, available_doses: 10) }
  let!(:reachable_users_service) { ReachableUsersService.new(campaign) }

  describe "get_vaccination_center_grid_cells" do
    it "covering is valid" do
      range = ::GridCoordsService.new(vaccination_center.lat, vaccination_center.lon).get_covering(campaign.max_distance_in_meters)
      expect(range[:center_cell][:i]).to eq(16566)
      expect(range[:center_cell][:j]).to eq(12164)
      expect(range[:dist_cells]).to eq(6)
      expect(range[:cells].length).to eq(113)

      lat_lon_center = get_lat_lng_for_number(range[:center_cell][:i], range[:center_cell][:j], DEFAULT_ZOOM_LEVEL)
      expect(lat_lon_center[:lat]).to be_within(0.01).of(42)
      expect(lat_lon_center[:lon]).to be_within(0.01).of(2)
    end
  end

  describe "get_users_with_random should find users" do
    before do
      User.create(
        firstname: Faker::Name.first_name,
        lastname: Faker::Name.last_name,
        email: Faker::Internet.unique.email(domain: "covidliste.com"),
        birthdate: Faker::Date.between(from: 100.years.ago, to: 55.years.ago),
        address: Faker::Address.full_address,
        phone_number: "+33601020304",
        toc: true,
        statement: true,
        confirmed_at: Time.now.utc,
        lat: 42,
        lon: 2,
      )
    end
    it "get user" do
      resp = reachable_users_service.get_users_with_random(5)
      user = resp[0]

      expect(user.grid_i).to be_within(2).of(16565)
      expect(user.grid_j).to be_within(2).of(12163)
    end
  end

  describe "get_users_with_random should not find users" do
    before do
      User.create(
        firstname: Faker::Name.first_name,
        lastname: Faker::Name.last_name,
        email: Faker::Internet.unique.email(domain: "covidliste.com"),
        birthdate: Faker::Date.between(from: 100.years.ago, to: 55.years.ago),
        address: Faker::Address.full_address,
        phone_number: "+33601020304",
        toc: true,
        statement: true,
        confirmed_at: Time.now.utc,
        lat: 42.01665183556824,
        lon: 1.93359375,
      )
    end
    it "get user" do
      resp = reachable_users_service.get_users_with_random(5)
      expect(resp.length).to eq(0)
    end
  end
end
