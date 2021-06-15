require "rails_helper"

RSpec.describe "Redirects", type: :request do
  describe "From a matches email to delete the account" do
    it "redirects to the confirm_destroy_profile_path" do
      match = create(:match)

      get legacy_edit_matches_users_path(match_confirmation_token: match.match_confirmation_token)
      expect(response).to redirect_to(%r{#{confirm_destroy_profile_path}})

      auth_token = Rack::Utils.parse_query(URI.parse(response.location).query).fetch("authentication_token")
      expect(User.find_signed(auth_token, purpose: "users.destroy")).to eq(match.user)
    end

    it "redirects to the root_path when the token is wrong" do
      match = create(:match)
      get legacy_edit_matches_users_path(match_confirmation_token: match.match_confirmation_token + "foo")
      expect(response).to redirect_to(root_path)
    end

    it "redirects to the root_path when the user is anynomized" do
      match = create(:match)
      match.user.anonymize!
      get legacy_edit_matches_users_path(match_confirmation_token: match.match_confirmation_token)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "From a slot alert email to delete the account" do
    it "redirects to the confirm_destroy_profile_path" do
      slot_alert = create(:slot_alert)

      get legacy_edit_slot_alerts_users_path(token: slot_alert.token)
      expect(response).to redirect_to(%r{#{confirm_destroy_profile_path}})

      auth_token = Rack::Utils.parse_query(URI.parse(response.location).query).fetch("authentication_token")
      expect(User.find_signed(auth_token, purpose: "users.destroy")).to eq(slot_alert.user)
    end

    it "redirects to the root_path when the token is wrong" do
      slot_alert = create(:slot_alert)
      get legacy_edit_slot_alerts_users_path(token: slot_alert.token + "foo")
      expect(response).to redirect_to(root_path)
    end

    it "redirects to the root_path when the user is anynomized" do
      slot_alert = create(:slot_alert)
      slot_alert.user.anonymize!
      get legacy_edit_slot_alerts_users_path(token: slot_alert.token)
      expect(response).to redirect_to(root_path)
    end
  end
end
