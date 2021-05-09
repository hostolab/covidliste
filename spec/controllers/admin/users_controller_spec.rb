require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
  describe "#index" do
    subject { get :index }

    context "admin" do
      let(:admin) { create(:user, :admin) }
      before { sign_in admin }

      it "load correctly" do
        expect(subject).to have_http_status :ok
        expect(assigns(:user)).to_not be_persisted
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

  describe "#resend_confirmation" do
    subject { post :resend_confirmation, params: {id: user.id} }

    context "admin" do
      let(:admin) { create(:user, :admin) }
      before { sign_in admin }

      context "user confirmed" do
        let!(:user) { create(:user) }
        it "respond succesfully" do
          post :resend_confirmation, params: {id: user.id}

          expect(response).to render_template(:index)
          expect(flash[:alert]).to match "Cet utilsateur a déjà été validé !"
        end
      end

      context "user not yet confirmed" do
        let!(:user) { create(:user, confirmed_at: nil) }
        it "sends and email" do
          post :resend_confirmation, params: {id: user.id}

          expect(response).to render_template(:index)
          expect(flash[:success]).to match "Le mail de confirmation a été renvoyé"
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
        expect(subject).to redirect_to(root_path)
      end
    end

    context "super admin" do
      let!(:user_1) { create(:user, email: "one@covidliste.com") }
      let!(:match) { create(:match, :available, user: user_1) }

      let!(:user_2) { create(:user, email: "two@covidliste.com") }
      let(:super_admin) { create(:user, :super_admin) }
      before { sign_in super_admin }

      subject { delete :destroy, params: {id: user_1.id} }

      it "deletes the user" do
        subject
        expect(user_1.reload.anonymized_at?).to eq(true)
      end

      it "refuses the user pending matches" do
        expect { subject }.to change { Match.pending.count }.by(-1)

        expect(match.reload.refused_at).to_not be_nil
        expect(match.user_id).to_not be_nil
        expect(match.user.anonymized_at?).to eq(true)
      end
    end
  end
end
