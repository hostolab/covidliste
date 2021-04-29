require "rails_helper"

describe GeocodeResourceJob do
  context "with resource is a center" do
    let!(:center) { create(:vaccination_center) }
    context "center with missing lat/lon" do
      it "does call geocoding and approximate coords" do
        allow_any_instance_of(GeocodingService).to receive(:call).and_return({
          lat: 48.12345,
          lon: 2.12345,
          zipcode: "75001",
          city: "Paris",
          geo_citycode: "Paris 75",
          geo_context: "Paris, Ile de France"
        })

        GeocodeResourceJob.new.perform(center)
        center.reload

        expect(center.lat).to eq 48.12345
        expect(center.lon).to eq 2.12345
      end
    end
  end
end
