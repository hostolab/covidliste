# frozen_string_literal: true

require "rails_helper"

RSpec.describe Match, type: :model do
  let!(:campaign) { create(:campaign) }
  let!(:campaign_batch) { create(:campaign_batch) }
  let!(:match) { create(:match, campaign_batch: campaign_batch, campaign: campaign) }
  let(:confirmed_match) { create(:match, :confirmed, campaign_batch: campaign_batch) }
  let(:now_utc) { Time.now.utc }
  let(:now) { double }

  describe "#create" do
    it "should copy User information" do
      user = create(:user,
        birthdate: Time.now.utc.to_date - 60.years,
        zipcode: "75001",
        city: "Paris",
        geo_citycode: "75001",
        geo_context: "GEO_CONTEXT")
      match = create(:match, user: user)
      match.reload
      expect(match.age).to eq 60
      expect(match.zipcode).to eq "75001"
      expect(match.city).to eq "Paris"
      expect(match.geo_citycode).to eq "75001"
      expect(match.geo_context).to eq "GEO_CONTEXT"
    end

    context "user has already a recent match" do
      let(:user) { create(:user) }
      before do
        create(:match, user: user)
      end
      it "should not create a second match" do
        expect { create(:match, user: user) }.to raise_error(ActiveRecord::RecordInvalid, "La validation a échoué : Cette personne a déjà été matchée récemment")
      end
    end
  end

  describe "#confirm!" do
    it "should flag the match as confirmed" do
      user = create(:user)
      match = create(:match, user: user)
      match.confirm!
      expect(match.confirmed?).to be true
    end

    context "When the match itself is already confirmed" do
      subject { confirmed_match.confirm! }
      it "raises Match::AlreadyConfirmedError" do
        expect { subject }.to raise_error(Match::AlreadyConfirmedError)
      end
    end

    context "When the match campaign has no #remaining_slots" do
      subject { match.confirm! }
      it "raises Match::DoseOverbookingError" do
        allow(campaign).to receive(:remaining_slots).and_return 0
        expect { subject }.to raise_error(Match::DoseOverbookingError)
      end
    end

    context "When the match campaign has at least 1 #remaining_slots" do
      subject { match.confirm! }
      it "updates the confirmed_at" do
        allow(campaign).to receive(:remaining_slots).and_return 1
        allow(now).to receive(:utc).and_return(now_utc)
        allow(Time).to receive(:now).and_return(now)

        expect { subject }.to change { match.confirmed_at }.from(nil).to(now_utc)
      end
    end
  end

  describe "#confirmable?" do
    context "When the match campaign has no #remaining_slots" do
      it "is not confirmable" do
        allow(campaign).to receive(:remaining_slots).and_return 0
        expect(match.confirmable?).to be false
      end
    end

    context "When the match campaign has at least 1 #remaining_slots" do
      it "is confirmable" do
        allow(campaign).to receive(:remaining_slots).and_return 1
        expect(match.confirmable?).to be true
      end
    end

    context "When the match itself is already confirmed" do
      it "is confirmable" do
        expect(confirmed_match.confirmable?).to be false
      end
    end
  end
end
