require "rails_helper"

RSpec.describe VaccinationCenter, type: :model do
  let(:vaccination_center) { create(:vaccination_center, lat: 42, lon: 2) }
  describe "validations" do
    context "when vaccination center has no lat neither lon" do
      subject { build(:vaccination_center, lat: nil, lon: nil) }

      context "on default context" do
        it "is valid" do
          expect(subject.valid?).to be true
        end
      end
      context "on validation_by_admin context" do
        it "is invalid" do
          expect(subject.invalid?(:validation_by_admin)).to be true
        end
      end
    end

    context "when it has incomplete address without zipcode" do
      context "on persistent context" do
        it "is valid" do
          expect(vaccination_center).to be_valid
        end
      end
      context "on new context" do
        it "is invalid" do
          new_vaccination_center = build(:vaccination_center, address: "21 Rue Bergère")
          expect(new_vaccination_center).not_to be_valid
          expect(new_vaccination_center.errors[:address]).to include(I18n.t("errors.messages.missing_zipcode"))
        end
      end
    end
  end

  describe "#reachable_users_query" do
    it "should not re-match someone who was matched less than a day ago" do
      campaign = create(:campaign, vaccination_center: vaccination_center, min_age: 50, max_age: 70)
      user1 = create(:user, lat: 42, lon: 2, birthdate: (Time.now.utc - 60.years))
      user2 = create(:user, lat: 42, lon: 2, birthdate: (Time.now.utc - 60.years))

      users = vaccination_center.reachable_users_query(
        min_age: campaign.min_age, max_age: campaign.max_age, max_distance_in_meters: campaign.max_distance_in_meters, limit: 10
      )
      expect(users).to include(user1)

      create(:match, user: user1, vaccination_center: vaccination_center, campaign: campaign, created_at: 23.hours.ago)

      users = vaccination_center.reachable_users_query(
        min_age: campaign.min_age, max_age: campaign.max_age, max_distance_in_meters: campaign.max_distance_in_meters, limit: 10
      )
      expect(users).not_to include(user1)
      expect(users).to include(user2)
    end

    it "should rematch someone who was matched more than a day ago" do
      campaign = create(:campaign, vaccination_center: vaccination_center, min_age: 50, max_age: 70)
      user1 = create(:user, lat: 42, lon: 2, birthdate: (Time.now.utc - 60.years))

      create(:match, user: user1, vaccination_center: vaccination_center, campaign: campaign, created_at: 25.hours.ago)

      users = vaccination_center.reachable_users_query(
        min_age: campaign.min_age, max_age: campaign.max_age, max_distance_in_meters: campaign.max_distance_in_meters, limit: 10
      )
      expect(users).to include(user1)
    end
  end
end
