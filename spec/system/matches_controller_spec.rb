require "rails_helper"

RSpec.describe MatchesController, type: :system do
  let!(:user) { create(:user) }
  let!(:partner) { create(:partner) }
  let!(:center) { create(:vaccination_center) }
  let!(:campaign) { create(:campaign, vaccination_center: center) }
  let!(:batch) { create(:campaign_batch, campaign: campaign, vaccination_center: center) }
  let!(:match_confirmation_token) { "abcd" }
  let!(:match) { create(:match, campaign_batch: batch, user: user, vaccination_center: center, match_confirmation_token: match_confirmation_token, expires_at: 1.hour.since) }

  subject { visit "/matches/#{match_confirmation_token}" }

  describe "GET show" do
    context "with a valid match" do
      it "it says une dose dispo" do
        subject
        expect(page).to have_text("Une dose est disponible")
        expect(page).to have_text("Je suis disponible")
        expect(page).to have_text(center.address)
      end
    end

    context "with a confirmed match" do
      before do
        match.update_column("confirmed_at", Time.now)
      end
      it "it says dispo confirmée" do
        subject
        expect(page).to have_text("Votre disponibilité est confirmée")
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
        visit "/matches/invalid-token"
        expect(page).to have_current_path(root_path)
      end
    end

    context "when another match has already been confirmed" do
      before do
        match.update_column("confirmed_at", Time.now)
  end

      it "handle the disappointment gracefully" do
        visit "/matches/#{second_match_confirmation_token}"

        expect(page).to have_text("La dose n'est plus disponible 😢")
        expect(page).to have_text("Nous sommes désolés, un autre volontaire a été plus rapide que vous.")
        expect(page).to have_text("Celà arrive parfois car pour être certains qu'aucune dose ne soit perdue nous contactons plusieurs volontaires")
        expect(page).not_to have_text("Une dose est disponible")
        expect(page).not_to have_text("Je suis disponible")
end
    end
