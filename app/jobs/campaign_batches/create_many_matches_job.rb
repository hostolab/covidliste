module CampaignBatches
  class CreateManyMatchesJob < ApplicationJob
    queue_as :critical

    def perform(campaign_batch)
      CreateMatchesForEligibleUsersLater.new(campaign_batch).call
    end

    class CreateMatchesForEligibleUsersLater
      def initialize(campaign_batch)
        @campaign_batch = campaign_batch
      end

      def call
        eligible_users.find_each do |user|
          CreateOneMatchJob.perform_later(user.id, @campaign_batch.id)
        end
      end

      private

      def campaign
        @campaign_batch.campaign
      end

      def vaccination_center
        campaign.vaccination_center
      end

      def eligible_users
        User
          .where(no_confirmed_match_exists)
          .near([vaccination_center.lat, vaccination_center.lon], campaign.max_distance_in_meters, unit: :m)
          .reorder(id: :asc)
          .limit(@campaign_batch.size)
          .select(:id)
      end

      def no_confirmed_match_exists
        ActiveRecord::Base.sanitize_sql([
          no_confirmed_match_exists_clause,
          {
            most_ancient_valid_birthdate: most_ancient_valid_birthdate,
            most_recent_valid_birthdate: most_recent_valid_birthdate
          }
        ])
      end

      def no_confirmed_match_exists_clause
        <<~SQL.squish
          NOT EXISTS (
            SELECT 1
            FROM matches
            WHERE matches.user_id = users.id
            AND matches.confirmed_at IS NOT NULL
          )
          AND users.birthdate BETWEEN :most_ancient_valid_birthdate AND :most_recent_valid_birthdate
        SQL
      end

      def now
        @now ||= Time.zone.today
      end

      def most_ancient_valid_birthdate
        now - (campaign.max_age + 1).years + 1.day
      end

      def most_recent_valid_birthdate
        now - campaign.min_age.years
      end
    end
  end
end
