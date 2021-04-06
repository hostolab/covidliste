module CampaignBatches
  class CreateOneMatchJob < ApplicationJob
    queue_as :default

    def perform(user_id, campaign_batch_id)
      match = build_match(user_id, campaign_batch_id)

      send_email(user_id, match.token)

      match.sent_at = Time.zone.now
      match.save!
    end

    private

    def build_match(user_id, campaign_batch_id)
      campaign = find_campaign(campaign_batch_id)

      Match.new(
        vaccination_center_id: campaign.vaccination_center_id,
        campaign_id: campaign.id,
        campaign_batch_id: campaign_batch_id,
        user_id: user_id,
        token: generate_token(user_id)
      )
    end

    def find_campaign(campaign_batch_id)
      Campaign
        .joins(:campaign_batches)
        .merge(CampaignBatch.where(id: campaign_batch_id))
        .first
    end

    def generate_token(user_id)
      # TODO: generate a token (a signed JWT for instance?)
    end

    def send_email(user_id, match_token)
      # TODO: implement mailer
    end
  end
end
