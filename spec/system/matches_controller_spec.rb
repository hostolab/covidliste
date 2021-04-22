require "rails_helper"

RSpec.describe MatchesController, type: :system do
  let(:partner) { create(:partner) }
  let(:center) { create(:vaccination_center) }
  let(:campaign) { create(:campaign, vaccination_center: center, available_doses: 5) }
  let(:batch) { create(:campaign_batch, campaign: campaign, vaccination_center: center) }

  # subject { visit "/matches/#{match_confirmation_token}" }

  describe "GET show" do
    context "with a valid match" do
      let(:match) { create(:match, :available, campaign_batch: batch, vaccination_center: center, campaign: campaign) }

      it "it says une dose dispo" do
        visit "/matches/#{match.match_confirmation_token}"

        expect(page).to have_text("Une dose est disponible")
        expect(page).to have_text("Je suis disponible")
        expect(page).to have_text(center.address)

        click_on("Je suis disponible")
        expect(page).to have_text("Vous devez renseigné votre identité")

        fill_in :firstname, with: Faker::Name.first_name
        click_on("Je suis disponible")
        expect(page).to have_text("Vous devez renseigné votre identité")

        fill_in :firstname, with: Faker::Name.first_name
        fill_in :lastname, with: Faker::Name.last_name
        click_on("Je suis disponible")
        expect(page).not_to have_text("Vous devez renseigné votre identité")
        expect(page).to have_text("Votre disponibilité est confirmée")
        expect(page).to have_text(center.address)
      end
    end

    context "with a confirmed match" do
      let(:match) { create(:match, :confirmed, campaign_batch: batch, vaccination_center: center, campaign: campaign) }

      it "it says dispo confirmée" do
        visit "/matches/#{match.match_confirmation_token}"

        expect(page).to have_text("Votre disponibilité est confirmée")
        expect(page).to have_text(center.address)
      end
    end

    context "with a expired match" do
      let(:match) { create(:match, :expired, campaign_batch: batch, vaccination_center: center, campaign: campaign) }

      it "it says delai dépassé" do
        visit "/matches/#{match.match_confirmation_token}"

        expect(page).to have_text("Le délai de confirmation est dépassé")
      end
    end

    context "with an invalid token" do
      it "redirects to root" do
        visit "/matches/invalid-token"

        expect(page).to have_current_path(root_path)
      end
    end

    context "when the campaign has no #remaining_slots" do
      # confirm all the slots
      before do
        while campaign.remaining_slots > 0
          create(:match, :confirmed, campaign: campaign)
        end
      end

      let(:match) { create(:match, :available, campaign_batch: batch, vaccination_center: center, campaign: campaign) }

      it "handle the user's disappointment gracefully" do
        visit "/matches/#{match.match_confirmation_token}"

        expect(page).to have_text("La dose n'est plus disponible 😢")
        expect(page).to have_text("Nous sommes désolés, un autre volontaire a été plus rapide que vous.")
        expect(page).to have_text("Pour qu'aucune dose ne soit perdue, nous contactons quand c'est possible plusieurs volontaires.")
        expect(page).to have_text("Dans de rares cas, il arrive que toutes les doses soient prises.")
        expect(page).not_to have_text("Une dose est disponible")
        expect(page).not_to have_text("Je suis disponible")
      end
    end

    context "when another match has been confirmed while I was already browsing the match page" do
      # confirm all the slots but one
      before do
        while campaign.remaining_slots > 1
          create(:match, :confirmed, campaign: campaign)
        end
      end

      let(:match) { create(:match, :available, campaign_batch: batch, vaccination_center: center, campaign: campaign) }

      it "handle the user's disappointment gracefully" do
        visit "/matches/#{match.match_confirmation_token}"

        # A volunteer confirms a few seconds before me
        # while I'm browsing the match show page
        create(:match, :confirmed, campaign: campaign)

        fill_in :firstname, with: Faker::Name.first_name
        fill_in :lastname, with: Faker::Name.last_name
        click_on("Je suis disponible")
        expect(page).to have_text("La dose n'est plus disponible 😢")
      end
    end
  end
end
