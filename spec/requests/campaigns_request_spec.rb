require "rails_helper"

RSpec.describe "Campaigns", type: :request do
  context "Simulator" do
    it "should simulate a campaign" do
      partner = create(:partner)
      vaccination_center = create(:vaccination_center)
      vaccination_center.update(confirmed_at: Time.now.utc)
      vaccination_center.partners << partner

      sign_in partner

      path = "/partners/vaccination_centers/#{vaccination_center.id}/campaigns/simulate_reach"
      headers = {"CONTENT_TYPE" => "application/json"}
      post path, params: {
        min_age: 55,
        max_age: 65,
        max_distance_in_meters: 1000,
        available_doses: 10,
        vaccine_type: Vaccine::Brands::ASTRAZENECA
      }.to_json, headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/json; charset=utf-8")
      json_response = JSON.parse(response.body)
      expect(json_response["reach"]).to eq 1 # Special case in dev/test envs
      expect(json_response["enough"]).to eq false
    end
  end
end
