require "rails_helper"

RSpec.describe "Matches", type: :request do
  let!(:user) { create(:user) }
  let!(:center) { create(:vaccination_center) }
  let!(:campaign) { create(:campaign, vaccination_center: center) }
  let!(:match_confirmation_token) { "abcd" }
  let!(:match) { create(:match, user: user, vaccination_center: center, match_confirmation_token: match_confirmation_token, expires_at: 1.hour.since, campaign: campaign) }

  describe "update" do
    it "will confirm a valid match with age and name confirmation" do
      expect {
        patch match_path(match_confirmation_token), params: {
          user: {
            firstname: "Jean",
            lastname: "Dupont"
          },
          confirm_age: "1",
          confirm_name: "1",
          confirm_distance: "1",
          confirm_hours: "1"
        }
      }.to change { match.reload.confirmed_at }
    end

    it "will not confirm a valid match without age or name confirmation" do
      expect {
        patch match_path(match_confirmation_token), params: {
          user: {
            firstname: "Jean",
            lastname: "Dupont"
          }
        }
      }.not_to change { match.reload.confirmed_at }
    end

    it "will not confirm an expired match" do
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
