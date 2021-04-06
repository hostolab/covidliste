require 'rails_helper'

RSpec.describe CampaignBatches::CreateManyMatchesJob, type: :job do
  subject(:perform_job) { described_class.new.perform(campaign_batch.id) }

  let(:execution_time) { Time.zone.parse('2021-04-05T17:00:00+02:00') }

  def build_confirmed_match
    FactoryBot.build(:match, :confirmed)
  end

  def build_unconfirmed_match
    FactoryBot.build(:match)
  end

  let(:campaign) do
    create(
      :campaign,
      :from_paris,
      min_age:                34,
      max_age:                65,
      max_distance_in_meters: 150_000
    )
  end

  let(:campaign_batch) do
    create(
      :campaign_batch,
      campaign:           campaign,
      vaccination_center: campaign.vaccination_center,
      size:               1
    )
  end

  let(:eligible_birthdate_1) { Date.parse('1955-04-06') }
  let(:eligible_birthdate_2) { Date.parse('1987-04-05') }
  let(:ineligible_birthdate_1) { Date.parse('1955-04-05') }
  let(:ineligible_birthdate_2) { Date.parse('1987-04-06') }

  let!(:ineligible_user_from_paris_1) { create(:user, :from_paris, birthdate: ineligible_birthdate_1, matches: [build_unconfirmed_match]) }
  let!(:ineligible_user_from_paris_2) { create(:user, :from_paris, birthdate: eligible_birthdate_1, matches: [build_confirmed_match]) }

  let!(:eligible_user_from_paris_1) { create(:user, :from_paris, birthdate: eligible_birthdate_1, matches: [build_unconfirmed_match]) }
  let!(:eligible_user_from_paris_2) { create(:user, :from_paris, birthdate: eligible_birthdate_2, matches: []) }

  let!(:ineligible_user_from_lyon) { create(:user, :from_lyon, birthdate: ineligible_birthdate_2) }
  let!(:eligible_user_from_lyon) { create(:user, :from_lyon, birthdate: eligible_birthdate_1) }

  around(:each) do |example|
    travel_to(execution_time) do
      example.run
    end
  end

  it 'should plan a job to create a Match for each eligible user' do
    expect(CampaignBatches::CreateOneMatchJob).to receive(:perform_later).once.with(eligible_user_from_paris_1.id, campaign_batch.id)

    perform_job
  end
end
