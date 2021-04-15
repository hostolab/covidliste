require "rails_helper"

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
          accept_confirm_modal do
            find_by_id(dom_id(user, :delete)).click
          end
          expect(page).to have_text "l'utilisateur a été supprimé."
          expect { user.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
