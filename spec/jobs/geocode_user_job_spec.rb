require 'rails_helper'

describe GeocodeUserJob do
  let!(:user) { create(:user) }

  subject { described_class.perform_now(user.id)}

  before(:each) do 
    allow_any_instance_of(GeocodingService).to receive(:geocode).and_return({
      lat: 48.12345,
      lon: 2.12345,
      postal_code: "75001"
    })
  end
  
  context "user with missing lat/lon" do
    it "does call geocoding and approximate coords" do
      subject
      user.reload
      expect(user.lat.to_f).to eq 48.123
      expect(user.lon.to_f).to eq 2.123
    end

    context "user with lat/lon" do
      before { user.update(lat: 55.12345, lon: 1.12345) }
      it "does not run geocoding but still approximate coords" do
        subject
        user.reload
        expect(user.lat.to_f).to eq 55.123
        expect(user.lon.to_f).to eq 1.123
      end
    end
  end

end
