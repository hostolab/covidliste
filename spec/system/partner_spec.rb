require "rails_helper"

RSpec.describe "Partners", type: :system do
  context "sign up" do
    let(:partner) { build(:partner) }
    it "can sign up" do
      expect do
        visit partenaires_inscription_path

        expect(page).to have_selector(:id, "health-professionnal")

        find("#health-professionnal").click
        expect(page).to have_selector(:id, "partner_name")

        accept_confirm do
          fill_in :partner_name, with: Faker::Name.last_name
          fill_in :partner_phone_number, with: generate(:french_phone_number)
          fill_in :partner_email, with: "hello+#{(rand * 10000).to_i}@covidliste.com" # needs valid email here
          fill_in :partner_password, with: Faker::Internet.password
          click_on "create-new-partner"
        end
      end.to change { Partner.count }.by(1)
    end
  end

  context "after login" do
    context "confirmed partner" do
      let(:partner_confirmed) { create(:partner) }

      scenario "login as a confirmed partner" do
        visit new_partner_session_path

        fill_in :partner_email, with: partner_confirmed.email
        fill_in :partner_password, with: partner_confirmed.password
        click_on "Connexion"

        expect(page).to have_current_path(partners_vaccination_centers_path)
      end
    end

    context "unconfirmed partner" do
      let(:partner_confirmed) { create(:partner, confirmed_at: nil) }

      scenario "login as an unconfirmed partner" do
        visit new_partner_session_path

        fill_in :partner_email, with: partner_confirmed.email
        fill_in :partner_password, with: partner_confirmed.password
        click_on "Connexion"

        expect(page).to have_current_path(new_partner_session_path)
      end
    end
  end
end
