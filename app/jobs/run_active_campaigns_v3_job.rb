class RunActiveCampaignsV3Job < ApplicationJob
  queue_as :critical

  def perform
    Rails.logger.info("Run RunActiveCampaignsV3Job")
    Campaign.running.each do |campaign|
      next unless campaign.matching_algo_v3?
      RunCampaignV3Job.perform_later(campaign.id)
      NotifyMatchesBySmsJob.perform_later(campaign.id)
    end
  end
end
