require "rails_helper"

RSpec.describe "Admin campaigns page", type: :system do
  describe "/admin/campaigns path" do
    context "user is logged as an admin" do
      let(:user) { create(:user, :admin) }
      before { login_as(user) }

      it "loads properly" do
        visit admin_campaigns_path
        expect(page).to have_current_path(admin_campaigns_path)
      end
    end

    context "user is logged as a super admin" do
      let(:user) { create(:user, :super_admin) }
      before { login_as(user) }

      it "loads properly" do
        visit admin_campaigns_path
        expect(page).to have_current_path(admin_campaigns_path)
      end
    end
  end
end
