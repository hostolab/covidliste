require "rails_helper"

RSpec.describe "Matches", type: :request do
  let!(:user) { create(:user) }
  let!(:center) { create(:vaccination_center) }
  let!(:campaign) { create(:campaign, vaccination_center: center) }
  let!(:batch) { create(:campaign_batch, campaign: campaign, vaccination_center: center) }
  let!(:match_confirmation_token) { "abcd" }
  let!(:match) { create(:match, campaign_batch: batch, user: user, vaccination_center: center, match_confirmation_token: match_confirmation_token, expires_at: 1.hour.since, campaign: campaign) }

  describe "update" do
    it "it will confirm a valid match" do
      expect {
        patch match_path(match_confirmation_token), params: {
          firstname: "Jean",
          lastname: "Dupont"
        }
      }.to change { match.reload.confirmed_at }
    end

    it "it will not confirm an expired match" do
      match.update_column("expires_at", 5.minutes.ago)

      expect {
        patch match_path(match_confirmation_token), params: {
          firstname: "Jean",
          lastname: "Dupont"
        }
      }.not_to change { match.reload.confirmed_at }
    end
  end
end
