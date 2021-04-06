require "rails_helper"

RSpec.describe CampaignBatches::CreateOneMatchJob, type: :job do
  subject(:perform_job) { described_class.new.perform(user.id, campaign_batch.id) }

  let(:execution_time) { Time.zone.parse("2021-04-05T17:00:00+02:00") }

  let(:campaign) { create(:campaign) }

  let(:campaign_batch) { create(:campaign_batch, campaign: campaign, duration_in_minutes: 10) }

  around(:each) do |example|
    travel_to(execution_time) do
      example.run
    end
  end

  let(:user) { create(:user) }

  it "creates the expected Match with the expected :sent_at/:expires_at values" do
    expect { perform_job }.to change { Match.count }.by(1)

    actual_match = user.matches.first

    expect(actual_match.campaign_id).to eql(campaign.id)
    expect(actual_match.campaign_batch_id).to eql(campaign_batch.id)
    expect(actual_match.sent_at).to eql(execution_time)
    expect(actual_match.expires_at).to eql(execution_time + campaign_batch.duration_in_minutes.minutes)
  end
end
