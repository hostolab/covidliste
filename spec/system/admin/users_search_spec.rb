require "rails_helper"

RSpec.describe "Admin Users Search", type: :system do
  describe "#search" do
    context "user is logged as an admin" do
      let(:admin_user) { create(:user, :admin) }
      let(:email) { "email@covidliste.com" }
      before { login_as(admin_user) }

      subject do
        visit search_admin_users_path
        fill_in :user_email, with: email
        click_on "C’est parti !"
      end

      context "with existing user" do
        let(:user) { create(:user, email: email) }
        it "should find the user" do
          subject
          expect(page).to have_text(email)
        end
      end

      context "without user in DB" do
        it "should not find anything" do
          subject
          expect(page).to have_text("Aucun utilisateur trouvé avec cette adresse")
        end
      end
    end
  end
end
