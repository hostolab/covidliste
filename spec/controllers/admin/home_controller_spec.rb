require "rails_helper"

RSpec.describe Admin::HomeController, type: :controller do
  describe "#show" do
    subject { get :index, params: {locale: "fr"} }

    context "user is logged as an admin" do
      let(:user) { create(:user, :admin) }
      before { sign_in user }

      it "loads properly" do
        expect(subject).to have_http_status :ok
      end
    end

    context "user is logged as a super admin" do
      let(:user) { create(:user, :super_admin) }
      before { sign_in user }

      it "loads properly" do
        expect(subject).to have_http_status :ok
      end
    end

    context "user is logged as a standard user" do
      let(:user) { create(:user) }
      before { sign_in user }

      it "redirects user to root page" do
        expect(subject).to redirect_to root_path
      end
    end

    context "visitor is not logged at all" do
      it "redirects to login page" do
        expect(subject).to redirect_to new_user_session_path
      end
    end
  end
end
