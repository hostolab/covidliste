require "rails_helper"

RSpec.describe MatchesController, type: :system do
  let!(:user) { create(:user) }
  let!(:second_user) { create(:user) }
  let!(:partner) { create(:partner) }
  let!(:center) { create(:vaccination_center, :from_paris) }
  let!(:campaign) { create(:campaign, vaccination_center: center) }
  let!(:match_confirmation_token) { "abcd" }
  let!(:match) { create(:match, user: user, vaccination_center: center, match_confirmation_token: match_confirmation_token, expires_at: 1.hour.since, campaign: campaign) }

  subject { visit match_path(match_confirmation_token, source: "sms") }

  describe "GET show" do
    context "with a valid match" do
      it "confirms the match only when all inputs are filled" do
        subject
        expect(page).to have_text("Une dose est disponible")
        expect(page).to have_text("Je réserve la dose")
        expect(page).to have_text("Distance du centre de vaccination")
        expect(page).to have_field("user_firstname", with: user.firstname)
        expect(page).to have_field("user_lastname", with: user.lastname)

        fill_in :user_firstname, with: user.firstname
        fill_in :user_lastname, with: ""
        check :confirm_age
        check :confirm_name
        click_on("Je réserve la dose")
        expect(page).to have_text("Vous devez renseigner votre identité")

        fill_in :user_firstname, with: ""
        fill_in :user_lastname, with: user.lastname
        check :confirm_age
        check :confirm_name
        click_on("Je réserve la dose")
        expect(page).to have_text("Vous devez renseigner votre identité")

        fill_in :user_firstname, with: user.firstname
        fill_in :user_lastname, with: user.lastname
        check :confirm_age
        check :confirm_name
        click_on("Je réserve la dose")
        expect(page).not_to have_text("Vous devez renseigner votre identité")
        expect(page).to have_text("Votre disponibilité est confirmée")
        expect(page).to have_text("Adresse du centre de vaccination")
        expect(page).to have_text(center.address)
        match.reload
        expect(match.sms_first_clicked_at).to_not eq(nil)
      end
    end

    context "with a confirmed match" do
      before do
        match.update_column("confirmed_at", Time.now)
      end
      it "it says dispo confirmée" do
        subject
        expect(page).to have_text("Votre disponibilité est confirmée")
        expect(page).to have_text("Adresse du centre de vaccination")
        expect(page).to have_text(center.address)
      end
    end

    context "with an expired match" do
      before do
        match.update_column("expires_at", 5.minutes.ago)
      end

      it "it says delai dépassé" do
        subject
        expect(page).to have_text("Le délai de confirmation est dépassé")
      end
    end

    context "with an invalid token" do
      it "redirects to root" do
        visit match_path("invalid-token")
        expect(page).to have_current_path(root_path)
      end
    end

    context "when the campaign has no #remaining_doses" do
      # confirm all the slots
      before do
        while campaign.remaining_doses > 0
          create(:match, :confirmed, campaign: campaign)
        end
      end

      it "handle the user's disappointment gracefully" do
        visit match_path(match_confirmation_token)

        expect(page).to have_text("La dose n'est plus disponible 😢")
        expect(page).to have_text("Nous sommes désolés, un autre volontaire a été plus rapide que vous.")
        expect(page).to have_text("Pour qu'aucune dose ne soit perdue, nous contactons quand c'est possible plusieurs volontaires.")
        expect(page).to have_text("Dans de rares cas, il arrive que toutes les doses soient prises.")
        expect(page).not_to have_text("Une dose est disponible")
        expect(page).not_to have_text("Je réserve la dose")
      end
    end

    context "when another match has been confirmed while I was already browsing the match page" do
      # confirm all the slots but one
      before do
        while campaign.remaining_doses > 1
          create(:match, :confirmed, campaign: campaign)
        end
      end

      it "handle the user's disappointment gracefully" do
        already_confirmed_count = Match.where(confirmation_failed_reason: "Match::AlreadyConfirmedError").count
        visit match_path(match_confirmation_token)

        # A volunteer confirms a few seconds before me
        # while I'm browsing the match show page
        create(:match, :confirmed, campaign: campaign)

        fill_in :user_firstname, with: generate(:firstname)
        fill_in :user_lastname, with: generate(:lastname)
        check :confirm_age
        check :confirm_name
        click_on("Je réserve la dose")
        expect(page).to have_text("La dose n'est plus disponible 😢")
        Match.where(confirmation_failed_reason: "Match::AlreadyConfirmedError").count == already_confirmed_count + 1
      end
    end
  end
end
