require 'rails_helper'

describe GeocodeUserJob do
  let!(:user) { create(:user) }

  context "user with missing lat/lon" do
    it "does call geocoding and approximate coords" do
      allow_any_instance_of(GeocodingService).to receive(:geocode).and_return({
        lat: 48.12345,
        lon: 2.12345,
        postal_code: "75001"
      })

      GeocodeUserJob.new.perform(user.id)
      user.reload

      expect(user.lat).to eq 48.123
      expect(user.lon).to eq 2.123
    end

    context "user with lat/lon" do
      before { user.update(lat: 55.12345, lon: 1.12345) }
      it "does not run geocoding but still approximate coords" do
        expect(user.lat).to eq 55.123
        expect(user.lon).to eq 1.123
      end
    end
  end
end
