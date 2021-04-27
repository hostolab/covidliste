require "rails_helper"

describe RunCampaignJob do
  let!(:user) { create(:user) }
  let!(:partner) { create(:partner) }
  let!(:center) { create(:vaccination_center) }
  let(:available_doses) { 1 }
  let(:vaccine_type) { Vaccine::Brands::PFIZER }
  let(:min_age) { 18 }
  let(:max_age) { 99 }
  let(:starts_at) { Time.now.utc - 1.hours }
  let(:ends_at) { Time.now.utc + 6.hours }
  let!(:campaign) {
    create(:campaign, vaccination_center: center,
                      available_doses: available_doses,
                      vaccine_type: vaccine_type,
                      min_age: min_age,
                      max_age: max_age,
                      max_distance_in_meters: 50,
                      starts_at: starts_at,
                      ends_at: ends_at)
  }

  let(:reachable_users_query) { User.where(id: user.id) }

  subject { RunCampaignJob.new.perform(campaign) }

  before do
    Flipper.enable(:matching_algo_v2)
    allow_any_instance_of(Campaign).to receive(:reachable_users_query).and_return(reachable_users_query)
  end

  after do
    Flipper.disable(:matching_algo_v2)
  end

  context "with one reachable user" do
    it "should create a batch and a match" do
      subject
      expect(campaign.matches.count).to eq(1)
    end

    it "should send an email" do
      expect { subject }.to have_enqueued_job(SendMatchEmailJob).exactly(:once)
    end

    context "and with an already confirmed match" do
      before do
        Match.create!(
          campaign: campaign,
          vaccination_center: center,
          user: user,
          confirmed_at: Time.now.utc
        )
      end
      it "should end the campaign" do
        subject
        campaign.reload
        expect(campaign.status).to eq("completed")
      end
    end
  end

  context "when no reachable user" do
    let(:reachable_users_query) { User.none }
    it "should not create any match and complete the campaign" do
      subject
      expect(campaign.matches.any?).to eq(false)
    end
  end

  context "when campaign is canceled" do
    before do
      campaign.update(status: 2)
    end
    it "should not create any batch or match" do
      subject
      expect(campaign.matches.any?).to eq(false)
    end
  end

  context "when campaign is complete" do
    before do
      campaign.update(ends_at: Time.now.utc)
    end
    it "should end the campaign" do
      subject
      campaign.reload
      expect(campaign.status).to eq("completed")
    end
  end
end
