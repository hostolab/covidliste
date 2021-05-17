# frozen_string_literal: true

require "rails_helper"

describe Campaign, type: :model do
  describe "#to_csv" do
    let(:available_doses) { 10 }
    let!(:vaccination_center) { create(:vaccination_center, lat: 42, lon: 2) }
    let(:campaign) { build(:campaign, vaccination_center: vaccination_center, available_doses: available_doses) }
    let!(:match) { create(:match, campaign: campaign, confirmed_at: Time.now) }
    let!(:unconfirmed_match) { create(:match, campaign: campaign, confirmed_at: nil) }

    it "includes information about confirmed matches" do
      expect(campaign.to_csv).to include(
        "#{match.user.firstname},#{match.user.lastname},#{match.user.birthdate},#{match.user.human_friendly_phone_number},#{match.confirmed_at}"
      )
    end

    it "does not include any information about unconfirmed matches" do
      expect(campaign.to_csv).not_to include(unconfirmed_match.user.firstname)
    end
  end

  describe "validations" do
    let(:campaign) { build(:campaign) }
    it "is valid with valid attributes" do
      expect(campaign).to be_valid
    end

    it "is invalid with min_age less than 18" do
      campaign.min_age = 17

      expect(campaign).not_to be_valid
      expect(campaign.errors[:min_age]).to include("doit être supérieur à 17")
    end

    it "is invalid with max_age less than 17" do
      campaign.max_age = 17

      expect(campaign).not_to be_valid
      expect(campaign.errors[:max_age]).to include("doit être supérieur à 17")
    end

    it "is invalid with max_age less than min_age" do
      campaign.min_age, campaign.max_age = 100, 99

      expect(campaign).not_to be_valid
      expect(campaign.errors[:max_age]).to include("doit être supérieur à l’âge minimum")
    end

    it "is invalid with max_distance_in_meters equal to 0" do
      campaign.max_distance_in_meters = 0

      expect(campaign).not_to be_valid
      expect(campaign.errors[:max_distance_in_meters]).to include("doit être supérieur à 0")
    end

    it "is invalid with max_distance_in_meters exceeding MAX_DISTANCE_IN_KM" do
      campaign.max_distance_in_meters = Campaign::MAX_DISTANCE_IN_KM * 1_000 + 1

      expect(campaign).not_to be_valid
      expect(campaign.errors[:max_distance_in_meters]).to include("doit être inférieur ou égal à #{Campaign::MAX_DISTANCE_IN_KM * 1000}")
    end

    it "is invalid if starts_at does not precede ends_at" do
      campaign.starts_at = campaign.ends_at

      expect(campaign).not_to be_valid
      expect(campaign.errors[:ends_at]).to include("doit être postérieur à la date de début")
    end

    it "is invalid if starts_at and ends_at are not in the same day" do
      campaign.ends_at = campaign.starts_at + 1.day

      expect(campaign).not_to be_valid
      expect(campaign.errors[:ends_at]).to include("doit être le même jour que la date de début")
    end

    it "is invalid if vaccine_type is not present" do
      campaign.vaccine_type = nil

      expect(campaign).not_to be_valid
      expect(campaign.errors[:vaccine_type]).to include("doit être rempli(e)")
    end

    it "is invalid if available_doses is greater than MAX_DOSES" do
      campaign.available_doses = Campaign::MAX_DOSES + 1

      expect(campaign).not_to be_valid
      expect(campaign.errors[:available_doses]).to include("doit être inférieur ou égal à #{Campaign::MAX_DOSES}")
    end
  end

  describe "#reachable_users_query" do
    let!(:vaccination_center) { create(:vaccination_center, lat: 42, lon: 2) }
    it "should not re-match someone who was matched less than a hour ago" do
      campaign = create(:campaign, vaccination_center: vaccination_center, min_age: 50, max_age: 70)
      user1 = create(:user, lat: 42, lon: 2, birthdate: (Time.now.utc - 60.years))
      user2 = create(:user, lat: 42, lon: 2, birthdate: (Time.now.utc - 60.years))

      users = campaign.reachable_users_query(limit: 10)
      expect(users).to include(user1)

      create(:match, user: user1, campaign: campaign, created_at: 1.hours.ago)

      users = campaign.reachable_users_query(limit: 1)
      expect(users).not_to include(user1)
      expect(users).to include(user2)
    end

    it "should rematch someone who was matched more than a day ago" do
      campaign = create(:campaign, vaccination_center: vaccination_center, min_age: 50, max_age: 70)
      user1 = create(:user, lat: 42, lon: 2, birthdate: (Time.now.utc - 60.years))

      create(:match, user: user1, campaign: campaign, created_at: 25.hours.ago)

      users = campaign.reachable_users_query(limit: 10)
      expect(users).to include(user1)
    end
  end

  describe "cancel!" do
    let(:available_doses) { 10 }
    let(:vaccination_center) { create(:vaccination_center, lat: 42, lon: 2) }
    let(:campaign) { create(:campaign, vaccination_center: vaccination_center, available_doses: available_doses, min_age: 50, max_age: 70) }
    let(:user) { create(:user) }
    let!(:confirmed_match) { create(:match, campaign: campaign, user: user, confirmed_at: Time.now.utc) }
    it "should set remaining doses to zero" do
      campaign.canceled!
      campaign.reload
      expect(campaign.status).to eq("canceled")
      expect(campaign.available_doses).to eq(1)
    end
  end
end
