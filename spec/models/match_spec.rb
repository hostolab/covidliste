# frozen_string_literal: true

require "rails_helper"

RSpec.describe Match, type: :model do
  let(:vaccination_center) { create(:vaccination_center, :from_paris) }
  let(:campaign) { create(:campaign, vaccination_center: vaccination_center, ends_at: 2.hours.from_now) }
  let(:match) { create(:match, campaign: campaign, vaccination_center: vaccination_center) }
  let(:confirmed_match) { create(:match, :confirmed) }
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

    it "should increment user matches count" do
      user = create(:user,
        birthdate: Time.now.utc.to_date - 60.years,
        zipcode: "75001",
        city: "Paris",
        geo_citycode: "75001",
        geo_context: "GEO_CONTEXT")
      create(:match, user: user)
      user.reload
      expect(user.matches_count).to eq(1)
    end

    context "same campaign" do
      let(:user) { create(:user) }
      before do
        create(:match, user: user, campaign: campaign)
      end
      it "should not create a second match for the same campaign" do
        expect { create(:match, user: user, campaign: campaign) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "user has already too many matches" do
      let(:user) { create(:user) }
      before do
        5.times.each do |i|
          create(:match, user: user)
        end
      end
      it "should not create a second match" do
        expect { create(:match, user: user) }.to raise_error(ActiveRecord::RecordInvalid, "La validation a échoué : Too many matches for this user")
      end
    end
  end

  describe "#confirm!" do
    it "should flag the match as confirmed" do
      user = create(:user)
      match = create(:match, user: user)
      match.confirm!
      expect(match.confirmed?).to be true
      user.reload
      expect(user.match_confirmed_at).not_to be_nil
    end

    context "When the match itself is already confirmed" do
      subject { confirmed_match.confirm! }
      it "raises Match::AlreadyConfirmedError" do
        expect { subject }.to raise_error(Match::AlreadyConfirmedError)
      end
    end

    context "When the match campaign has no #remaining_doses" do
      subject { match.confirm! }
      it "raises Match::DoseOverbookingError" do
        allow(campaign).to receive(:remaining_doses).and_return 0
        expect { subject }.to raise_error(Match::DoseOverbookingError)
      end
    end

    context "When the match campaign has at least 1 #remaining_doses" do
      subject { match.confirm! }
      it "updates the confirmed_at" do
        allow(campaign).to receive(:remaining_doses).and_return 1
        allow(now).to receive(:utc).and_return(now_utc)
        allow(Time).to receive(:now).and_return(now)

        expect { subject }.to change { match.confirmed_at }.from(nil).to(now_utc)
      end
    end
  end

  describe "#confirmable?" do
    context "When the match campaign has no #remaining_doses" do
      it "is not confirmable" do
        allow(campaign).to receive(:remaining_doses).and_return 0
        expect(match.confirmable?).to be false
      end
    end

    context "When the match campaign has at least 1 #remaining_doses" do
      it "is confirmable" do
        allow(campaign).to receive(:remaining_doses).and_return 1
        expect(match.confirmable?).to be true
      end
    end

    context "When the match itself is already confirmed" do
      it "is confirmable" do
        expect(confirmed_match.confirmable?).to be false
      end
    end
  end

  describe "#set_expiration!" do
    before do
      travel_to Time.parse("2021-04-01 14:00:00")
    end
    after do
      travel_back
    end

    it "should set correct expiration" do
      match.reload
      match.set_expiration!
      match.reload
      expect(match.expires_at).to eq(campaign.ends_at)
    end

    context "campaign ending now" do
      before do
        campaign.update(ends_at: Time.now.utc)
        match.set_expiration!
        match.reload
        expect(match.expires_at).to eq(Time.now.utc)
      end
    end
  end

  describe "#multi match fallback" do
    it "should have other match" do
      users = create_list(:user, 2, birthdate: Time.now.utc.to_date - 60.years,
                                    zipcode: "75001",
                                    city: "Paris",
                                    geo_citycode: "75001",
                                    geo_context: "GEO_CONTEXT")
      u1 = users.first
      u2 = users.second

      vc1 = create(:vaccination_center, :from_paris)
      vc2 = create(:vaccination_center, :from_paris)

      c1 = create(:campaign, vaccination_center: vc1, ends_at: 2.hours.from_now, available_doses: 1)
      c2 = create(:campaign, vaccination_center: vc2, ends_at: 2.hours.from_now, available_doses: 1)

      m1 = create(:match, user: u1, campaign: c1, vaccination_center: vc1)
      m2 = create(:match, :confirmed, user: u2, campaign: c1, vaccination_center: vc1)
      m3 = create(:match, user: u1, campaign: c2, vaccination_center: vc2)

      m1.set_expiration!
      m2.set_expiration!
      m3.set_expiration!

      other = m1.find_other_available_match_for_user
      expect(other.id).to eq(m3.id)
    end

    it "should not have other match" do
      users = create_list(:user, 2, birthdate: Time.now.utc.to_date - 60.years,
                                    zipcode: "75001",
                                    city: "Paris",
                                    geo_citycode: "75001",
                                    geo_context: "GEO_CONTEXT")
      u1 = users.first
      u2 = users.second

      vc1 = create(:vaccination_center, :from_paris)

      c1 = create(:campaign, vaccination_center: vc1, ends_at: 2.hours.from_now, available_doses: 1)

      m1 = create(:match, user: u1, campaign: c1, vaccination_center: vc1)
      m2 = create(:match, :confirmed, user: u2, campaign: c1, vaccination_center: vc1)

      m1.set_expiration!
      m2.set_expiration!

      other = m1.find_other_available_match_for_user
      expect(other).to eq(nil)
    end
  end
end
