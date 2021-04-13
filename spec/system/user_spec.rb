require "rails_helper"

RSpec.describe "Users", type: :system do
  let(:user) { build(:user) }

  context "sign up" do
    it "can sign up" do
      expect do
        visit "/"
        fill_in :user_firstname, with: Faker::Name.first_name
        fill_in :user_lastname, with: Faker::Name.last_name
        fill_in :user_address, with: Faker::Address.full_address
        fill_in :user_phone_number, with: Faker::PhoneNumber.cell_phone
        fill_in :user_email, with: "hello+#{(rand * 10000).to_i}@covidliste.com" # needs valid email here
        fill_in :user_password, with: Faker::Internet.password
        check :user_statement
        check :user_toc
        click_on "Je m’inscris"
      end.to change { User.count }.by(1)
    end

    it "it rejects sign up if email is not unique" do
      user.save!

      expect do
        visit "/"
        fill_in :user_firstname, with: Faker::Name.first_name
        fill_in :user_lastname, with: Faker::Name.last_name
        fill_in :user_address, with: Faker::Address.full_address
        fill_in :user_phone_number, with: Faker::PhoneNumber.cell_phone
        fill_in :user_email, with: user.email # not unique
        fill_in :user_password, with: Faker::Internet.password
        check :user_statement
        check :user_toc
        click_on "Je m’inscris"
      end.not_to change { User.count }

      expect(page).to have_text("correspond déjà à une personne inscrit")
    end

    it "redirects a partner to their vaccination center page" do
      partner = create(:partner)
      visit new_partner_session_path

      fill_in :partner_email, with: partner.email
      fill_in :partner_password, with: partner.password
      click_on "Connexion"

      visit "/"

      expect(page).to have_text("Bonjour #{partner.name}")
    end
  end

  context "after login" do
    before do
      user.save!

      visit "/login"
      fill_in :user_email, with: user.email
      fill_in :user_password, with: user.password
      click_on "Connexion"

      expect(page).to have_text("Connecté(e).")
      expect(page).to have_text("Vos informations")
    end

    it "it allows me to edit personal information " do
      new_attributes = {
        firstname: Faker::Name.first_name,
        lastname: Faker::Name.last_name,
        address: Faker::Address.full_address
      }

      new_attributes.each do |key, new_value|
        fill_in "user_#{key}", with: new_value
      end

      click_on "Je modifie mes informations"
      expect(page).to have_text("Modifications enregistrées.")

      user.reload

      new_attributes.each do |key, value|
        expect(user.public_send(key)).to eq value
      end
    end

    it "it allows me to delete my account" do
      expect do
        accept_confirm "En confirmant, votre compte ainsi que toutes les données associées seront supprimées de nos serveurs. Êtes-vous sûr ?" do
          click_on "Supprimer mon compte"
        end
      end.to change { User.count }.by(-1)

      expect(page).to have_text("Votre compte a bien été supprimé.")
    end
  end
end
