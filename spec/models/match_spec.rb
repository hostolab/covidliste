# frozen_string_literal: true
require "rails_helper"

RSpec.describe Match, type: :model do
  let(:campaign_batch) { create(:campaign_batch) }
  let(:match) { create(:match, campaign_batch: campaign_batch) }
  let(:confirmed_match) { create(:match, :confirmed, campaign_batch: campaign_batch) }
  let(:now_utc) { Time.now.utc }
  let(:now) { double }

  describe "#confirm!" do
    it "should copy User information at confirmation" do
      user = create(:user,
        birthdate: Date.today - 60.years,
        zipcode: "75001",
        city: "Paris",
        geo_citycode: "75001",
        geo_context: "GEO_CONTEXT")

      match = create(:match, user: user)
      match.confirm!
      expect(match.age).to eq 60
      expect(match.zipcode).to eq "75001"
      expect(match.city).to eq "Paris"
      expect(match.geo_citycode).to eq "75001"
      expect(match.geo_context).to eq "GEO_CONTEXT"
    end

    context 'When the match is already confirmed' do
      subject { confirmed_match.confirm! }
      it 'raises Match::DoseOverbookingError' do
        expect {subject }.to raise_error(Match::DoseOverbookingError)
      end
    end

    context 'When the batch has already at least one match confirmed' do
      subject { match.confirm! }
      it 'raises Match::DoseOverbookingError' do
        confirmed_match
        expect{ subject }.to raise_error(Match::DoseOverbookingError)
      end
    end

    context 'When the match is confirmable' do
      subject { match.confirm! }
      it 'updates the confirmed_at' do
        allow(now).to receive(:utc).and_return(now_utc)
        allow(Time).to receive(:now).and_return(now)

        expect{ subject }.to change { match.confirmed_at }.from(nil).to(now_utc)
      end
    end
  end

  describe '#confirmable?' do
    context 'When the batch has already at least one match confirmed' do
      it 'is not confirmable' do
        confirmed_match
        expect(match.confirmable?).to be false
      end
    end

    context 'When the batch has no match confirmed' do
      it 'is confirmable' do
        expect(match.confirmable?).to be true
      end
    end

    context 'When the match is already confirmed' do
      it 'is confirmable' do
        expect(confirmed_match.confirmable?).to be false
      end
    end
  end
end
