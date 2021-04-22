require "rails_helper"

RSpec.describe "Matches", type: :request do
  let!(:match) { create(:match, :available) }

  describe "update" do
    it "it will confirm a valid match" do
      expect {
        patch "/matches/#{match.match_confirmation_token}", params: {
          firstname: "Jean",
          lastname: "Dupont"
        }
      }.to change { match.reload.confirmed_at }
    end

    it "it will not confirm an expired match" do
      match.update_column("expires_at", 5.minutes.ago)

      expect {
        patch "/matches/#{match.match_confirmation_token}", params: {
          firstname: "Jean",
          lastname: "Dupont"
        }
      }.not_to change { match.reload.confirmed_at }
    end
  end
end
