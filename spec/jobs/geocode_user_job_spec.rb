require 'rails_helper'

describe GeocodeUserJob do
  let!(:user) { create(:user) }

  subject { described_class.perform_now(user.id)}

  before(:each) do
    Geocoder.configure(:lookup => :test)
    Geocoder::Lookup::Test.set_default_stub(
      [
        {
          'coordinates'  => [48.8534, 2.3488],
          'address'      => 'Paris',
          'country_code' => '75001'
        }
      ]
    )
  end
  
  context "user with address" do
    it "does call geocoder and approximate coords" do
      subject
      user.reload
      expect(user.lat.to_f).to eq 48.853
      expect(user.lon.to_f).to eq 2.349
    end
  end

end
