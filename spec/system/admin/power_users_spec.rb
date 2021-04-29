require "rails_helper"

RSpec.describe "Admin Power Users", type: :system do
  describe "#index" do
    let!(:super_admin_user) { create(:user, :super_admin) }
    let!(:admin_user) { create(:user, :admin) }
    let!(:support_user) { create(:user, :support_member) }
    let(:user) { create(:user) }
    let!(:power_user) do
      user = create(:user)
      user.add_role(:admin)
      user.add_role(:hero)
      user.add_role(:invisible)
    end
    context "user is logged as a support member user" do
      before { login_as(support_user) }

      scenario "try to acces the page" do
        expect {
          visit admin_power_users_path
          expect(page).to have_text "test"
          # Needed for Capybara to wait enough time to throw exception
        }.to raise_error(ActionController::RoutingError)
      end
    end

    context "user is logged as an admin" do
      before { login_as(super_admin_user) }

      scenario "visit the power user page" do
        visit admin_power_users_path
        expect(page).to have_current_path admin_power_users_path

        # ensure only users with roles are listed
        expect(page).to have_text(super_admin_user.email)
        expect(page).to have_text(admin_user.email)
        expect(page).to_not have_text(user.email)

        # ensure all roles are listed
        Role.distinct.pluck(:name).each do |role|
          role_name = role
          if Rails.application.config.x.covidliste["admin_roles"].include? :"#{role}"
            role_config = Rails.application.config.x.covidliste["admin_roles"][:"#{role}"]
            role_name = role_config[:name] || role_name
          end
          expect(page).to have_text role_name
        end
      end
    end
  end
end
