require "rails_helper"

def robust_password
  "1G09_!9s08vUsa"
end

def display_partner_signup
  visit partenaires_inscription_path
  expect(page).to have_selector(:id, "health-professionnal")
  find("#health-professionnal").click
  expect(page).to have_selector(:id, "partner_name")
end

def fill_valid_partner
  fill_in :partner_name, with: Faker::Name.last_name
  fill_in :partner_phone_number, with: generate(:french_phone_number)
  fill_in :partner_email, with: "hello+#{(rand * 10000).to_i}@covidliste.com" # needs valid email here
  fill_in :partner_password, with: robust_password
  check :partner_statement
end

RSpec.describe "Partners", type: :system do
  let(:partner) { build(:partner) }

  context "sign up" do
    it "can sign up" do
      expect do
        display_partner_signup
        accept_confirm_modal do
          fill_valid_partner
          click_on "create-new-partner"
        end
      end.to change { Partner.count }.by(1)
    end

    it "rejects sign up if statement is not checked" do
      expect do
        display_partner_signup
        accept_confirm_modal do
          fill_valid_partner
          uncheck :partner_statement
          click_on "create-new-partner"
        end
      end.not_to change { Partner.count }
    end

    it "stores statement acceptance timestamps" do
      expect do
        display_partner_signup
        accept_confirm_modal do
          fill_valid_partner
          click_on "create-new-partner"
        end
      end.to change { Partner.count }.by(1)

      partner = Partner.last
      expect(partner.statement_accepted_at).not_to be_nil
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

  context "profile logged-in" do
    before do
      partner.save!

      visit new_partner_session_path
      fill_in :partner_email, with: partner.email
      fill_in :partner_password, with: partner.password
      click_on "Connexion"

      expect(page).to have_text("Connecté(e).")

      visit partners_path
    end

    it "it allows me to edit personal information " do
      new_attributes = {
        name: Faker::Name.name,
        phone_number: generate(:french_phone_number)
      }

      new_attributes.each do |key, new_value|
        fill_in "partner_#{key}", with: new_value
      end

      click_on "Je modifie mes informations"
      expect(page).to have_text("Modifications enregistrées.")

      partner.reload

      new_attributes.each do |key, value|
        if key == :phone_number
          expect(partner.phone_number).to end_with(new_attributes[:phone_number][1..].delete(" "))
        else
          expect(partner.public_send(key)).to eq value
        end
      end
    end

    it "it allows me to delete my account" do
      expect do
        accept_confirm_modal do
          click_on "Supprimer mon compte"
        end
      end.to change { Partner.count }.by(-1)

      expect(page).to have_text("Votre compte a bien été supprimé.")
    end

    it "it allows me to decline the delete" do
      expect do
        decline_confirm_modal do
          click_on "Supprimer mon compte"
        end
      end.to change { Partner.count }.by(0)
    end
  end
end
