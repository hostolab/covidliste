require "rails_helper"

RSpec.describe "Admin home page", type: :system do
  describe "/admin path" do
    context "user is logged as an admin" do
      let(:user) { create(:user, :admin) }
      before { login_as(user) }

      it "loads properly" do
        visit admin_path
        expect(page).to have_current_path(admin_path)
      end
    end

    context "user is logged as a super admin" do
      let(:user) { create(:user, :super_admin) }
      before { login_as(user) }

      it "loads properly" do
        visit admin_path
        expect(page).to have_current_path(admin_path)
      end
    end
  end
end
