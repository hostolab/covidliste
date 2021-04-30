require "rails_helper"

RSpec.describe "Destroy user account from match email", type: :system do
  let!(:user) { create(:user) }
  let!(:second_user) { create(:user) }
  let!(:partner) { create(:partner) }
  let!(:center) { create(:vaccination_center, :from_paris) }
  let!(:campaign) { create(:campaign, vaccination_center: center) }
  let!(:match_confirmation_token) { "abcd" }
  let!(:match) { create(:match, user: user, vaccination_center: center, match_confirmation_token: match_confirmation_token, expires_at: 1.hour.since, campaign: campaign) }

  subject { visit match_path(match_confirmation_token, source: "sms") }

  context "with a valid match" do
    scenario "the user can destroy he account" do
      visit edit_matches_users_path(match_confirmation_token: match_confirmation_token)
      expect(page).to have_current_path(edit_matches_users_path, ignore_query: true)
      expect(page).to have_selector(:id, dom_id(user, :delete))
      expect do
        accept_confirm_modal do
          click_on dom_id(user, :delete)
        end
      end.to change { User.count }.by(-1)
    end

    scenario "the user is not logged in" do
      visit edit_matches_users_path(match_confirmation_token: match_confirmation_token)
      expect(page).to have_selector(:id, dom_id(user, :delete))
      visit profile_path
      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
