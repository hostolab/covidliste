require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
  describe "#index" do
    subject { get :index }

    context "admin" do
      let(:admin) { create(:user, :admin) }
      before { sign_in admin }

      it "redirects to admin home page" do
        expect(subject).to redirect_to admin_path
      end
    end

    context "super admin" do
      let!(:user_1) { create(:user, email: "one@covidliste.com") }
      let!(:user_2) { create(:user, email: "two@covidliste.com") }
      let(:super_admin) { create(:user, :super_admin) }
      before { sign_in super_admin }

      it "load correctly" do
        expect(subject).to have_http_status :ok
        expect(assigns(:user)).to_not be_persisted
      end

      context "pass email filter as a param" do
        it "index returns all users" do
          get :index, params: {user: {email: user_1.email}}
          expect(assigns(:user)).to eq user_1
        end
      end
    end
  end

  describe "#destroy" do
    let!(:user) { create(:user) }
    subject { delete :destroy, params: {id: user.id} }

    context "admin" do
      let(:admin) { create(:user, :admin) }
      before { sign_in admin }

      it "does not allow to destroy the ressource" do
        expect(subject).to redirect_to(admin_path)
      end
    end

    context "super admin" do
      let!(:user_1) { create(:user, email: "one@covidliste.com") }
      let!(:user_2) { create(:user, email: "two@covidliste.com") }
      let(:super_admin) { create(:user, :super_admin) }
      before { sign_in super_admin }

      subject { delete :destroy, params: {id: user_1.id} }

      it "deletes the user" do
        expect { subject }.to change { User.count }.by(-1)
        expect { user_1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
