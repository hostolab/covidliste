module CampaignBatches
  class CreateOneMatchJob < ApplicationJob
    queue_as :default

    def perform(user, campaign_batch)
      match = build_match(user, campaign_batch)

      send_email(user)

      match.sms_sent_at = Time.zone.now
      match.save!
    end

    private

    def build_match(user, campaign_batch)
      Match.new(
        vaccination_center: campaign_batch.vaccination_center,
        campaign: campaign_batch.campaign,
        campaign_batch: campaign_batch,
        user: user,
      )
    end

    def send_email(user)
      # TODO: implement mailer
    end
  end
end
