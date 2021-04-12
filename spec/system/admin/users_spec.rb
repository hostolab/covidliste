require "rails_helper"

# RSpec.describe "Admin users page", type: :system do
#   describe "/admin/users path" do
#     context "user is logged as an admin" do
#       let(:user) { create(:user, :admin) }
#       before { login_as(user) }

#       it "cannot access this page" do
#         visit admin_users_path
#         expect(page).to have_current_path(admin_path)
#       end
#     end

#     context "user is logged as a super admin" do
#       let!(:user_1) { create(:user, email: "one@covidliste.com") }
#       let!(:user_2) { create(:user, email: "two@covidliste.com") }
#       let(:user) { create(:user, :super_admin) }
#       before { login_as(user) }

#       scenario "navigate from admin navbar" do
#         visit admin_path
#         find("#dropdown-admin").click
#         expect(page).to have_css("#admin_users", visible: true) # make sure it is visible before clickin on it
#         find("#admin_users").click
#         expect(page).to have_current_path(admin_users_path)
#       end

#       scenario "searching for a valid email and delete the user" do
#         visit admin_users_path

#         within "#new_user" do
#           fill_in "user_email", with: user_1.email
#           click_on "Chercher"
#         end

#         expect(page).to have_text "Un volontaire a été trouvé avec l'adresse email : #{user_1.email}"

#         accept_confirm do
#           find_by_id(dom_id(user_1, :delete)).click
#         end
#         expect(page).to have_text "l'utilisateur a été supprimé."
#         expect { user_1.reload }.to raise_error(ActiveRecord::RecordNotFound)
#       end

#       scenario "searching for a invalid email" do
#         visit admin_users_path

#         within "#new_user" do
#           fill_in "user_email", with: "wrong@covidliste.com"
#           click_on "Chercher"
#         end

#         expect(page).to have_text "Il n'y pas pas de volontaire avec l'adresse email : wrong@covidliste.com"
#       end
#     end
#   end
# end
RSpec.describe "Admin Users", type: :system do
  describe "#search" do
    context "user is logged as an admin" do
      let(:admin_user) { create(:user, :admin) }
      let(:email) { "email@covidliste.com" }
      before { login_as(admin_user) }

      subject do
        visit admin_users_path
        fill_in :user_email, with: email
        click_on "Chercher"
      end

      context "with existing user" do
        let!(:user) { create(:user, email: email) }
        it "should find the user" do
          subject
          expect(page).to have_text(email)
        end

        it "does not display a delete button" do
          subject
          expect(page).to_not have_text("Supprimer")
          expect(page).to_not have_selector(:id, dom_id(user, :delete))
        end
      end

      context "without user in DB" do
        it "should not find anything" do
          subject
          expect(page).to have_text("Aucun utilisateur trouvé avec cette adresse")
        end
      end
    end

    context "user is logged as a super admin" do
      let(:super_admin_user) { create(:user, :super_admin) }
      let(:email) { "email@covidliste.com" }
      before { login_as(super_admin_user) }

      subject do
        visit admin_users_path
        fill_in :user_email, with: email
        click_on "Chercher"
      end

      context "with existing user" do
        let!(:user) { create(:user, email: email) }
        it "should find the user" do
          subject
          expect(page).to have_text(email)
        end

        it "does allow to delete a user" do
          subject
          expect(page).to have_selector(:id, dom_id(user, :delete))
          accept_confirm do
            find_by_id(dom_id(user, :delete)).click
          end
          expect(page).to have_text "l'utilisateur a été supprimé."
          expect { user.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
