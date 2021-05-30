require "rails_helper"

RSpec.describe SendInactiveUserEmailsJob do
  describe ".inactive_user_ids" do
    subject(:inactive_user_ids) { described_class.inactive_user_ids(min_refused_matches, age_range, signed_up_date_range) }

    let(:min_refused_matches) { described_class::DEFAULT_MIN_REFUSED_MATCHES }
    let(:age_range) { described_class::DEFAULT_AGE_RANGE }
    let(:signed_up_date_range) { described_class::DEFAULT_SIGNED_UP_RANGE }

    let!(:matching_user) do
      create(:user, {
        birthdate: Date.new(1990, 1, 1),
        created_at: 20.days.ago,
        confirmed_matches_count: confirmed_matches_count,
        refused_matches_count: refused_matches_count,
        pending_matches_count: pending_matches_count,
        unanswered_matches_count: unanswered_matches_count
      })
    end

    let(:confirmed_matches_count) { 0 }
    let(:refused_matches_count) { 1 }
    let(:unanswered_matches_count) { 1 }
    let(:pending_matches_count) { 0 }

    it "returns the ids of users having refused, including unanswered matches, 2 or more matches" do
      expect(inactive_user_ids).to include(matching_user.id)
    end

    context "when a user have at least a pending match" do
      let(:pending_matches_count) { 1 }

      it "excludes users having pending matches" do
        expect(inactive_user_ids).not_to include(matching_user.id)
      end
    end

    context "when a user have at least a confirmed match" do
      let(:confirmed_matches_count) { 1 }

      it "excludes users having confirmed matches" do
        expect(inactive_user_ids).not_to include(matching_user.id)
      end
    end

    context "when a user refused too few matches" do
      let(:min_refused_matches) { 3 }

      it "excludes users having refused too few matches" do
        expect(inactive_user_ids).not_to include(matching_user.id)
      end
    end

    context "when a user is too young" do
      let(:age_range) { 55.. }

      it "excludes too young users" do
        expect(inactive_user_ids).not_to include(matching_user.id)
      end
    end

    context "when a user is too old" do
      let(:age_range) { ..20 }

      it "excludes too old users" do
        expect(inactive_user_ids).not_to include(matching_user.id)
      end
    end

    context "when a user was created too recently" do
      let(:signed_up_date_range) { ..1.month.ago }

      it "excludes users creted too recently" do
        expect(inactive_user_ids).not_to include(matching_user.id)
      end
    end

    context "when a user was created too far in the past" do
      let(:signed_up_date_range) { 10.days.ago.. }

      it "excludes users created too far in the past" do
        expect(inactive_user_ids).not_to include(matching_user.id)
      end
    end
  end
end
