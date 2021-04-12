require "rails_helper"

RSpec.describe "Admin users page", type: :system do
  describe "/admin/users path" do
    context "user is logged as an admin" do
      let(:user) { create(:user, :admin) }
      before { login_as(user) }

      it "cannot access this page" do
        visit admin_users_path
        expect(page).to have_current_path(admin_path)
      end
    end

    context "user is logged as a super admin" do
      let!(:user_1) { create(:user, email: "one@covidliste.com") }
      let!(:user_2) { create(:user, email: "two@covidliste.com") }
      let(:user) { create(:user, :super_admin) }
      before { login_as(user) }

      scenario "navigate from admin navbar" do
        visit admin_path
        find("#dropdown-admin").click
        expect(page).to have_css("#admin_users", visible: true) # make sure it is visible before clickin on it
        find("#admin_users").click
        expect(page).to have_current_path(admin_users_path)
      end

      scenario "searching for a valid email and delete the user" do
        visit admin_users_path

        within "#new_user" do
          fill_in "user_email", with: user_1.email
          click_on "Chercher"
        end

        expect(page).to have_text "Un volontaire a été trouvé avec l'adresse email : #{user_1.email}"

        accept_confirm do
          find_by_id(dom_id(user_1, :delete)).click
        end
        expect(page).to have_text "l'utilisateur a été supprimé."
        expect { user_1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      scenario "searching for a invalid email" do
        visit admin_users_path

        within "#new_user" do
          fill_in "user_email", with: "wrong@covidliste.com"
          click_on "Chercher"
        end

        expect(page).to have_text "Il n'y pas pas de volontaire avec l'adresse email : wrong@covidliste.com"
      end
    end
  end
end
