require "rails_helper"

RSpec.describe UserAuthenticationViaSignedId, type: :controller do
  controller(ApplicationController) do
    include UserAuthenticationViaSignedId

    before_action :authenticate_user_via_signed_id!, only: %i[index]
    before_action -> { authenticate_user_via_signed_id!(purpose: :testing) }, only: %i[show]

    def index
      render plain: ""
    end

    def new
      render plain: ""
    end

    def skip_pundit?
      true
    end
  end

  describe "when an authentication_token param is provided" do
    let(:user) { create(:user) }

    context "when the purpose of the authentication_token is properly set" do
      it "executes the controller's action" do
        get :index, params: {authentication_token: user.signed_id(purpose: "anonymous.index")}
        expect(response).to have_http_status(:ok)

        get :new, params: {authentication_token: user.signed_id(purpose: :testing)}
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the purpose of the authentication_token is not set" do
      it "redirects to the login page" do
        get :index, params: {authentication_token: user.signed_id}
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "when devise authentication is provided" do
    let(:user) { create(:user) }
    before { sign_in user }

    it "executes the controller's action" do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe "when no authentication is provided" do
    it "redirects to the login page" do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
