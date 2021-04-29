require "rails_helper"

RSpec.describe Partners::CampaignsController, type: :controller do
  render_views

  let!(:partner) { create(:partner) }
  let!(:center) { create(:vaccination_center, confirmed_at: 10.days.ago) }
  let!(:campaign) { create(:campaign, vaccination_center: center) }

  describe "#show" do
    subject { get :show, params: {id: campaign.id} }

    context "with partner logged in" do
      before do
        center.partners << partner
        sign_in partner
      end
      it "loads properly" do
        expect(subject).to have_http_status :ok
      end
    end
  end
end
