class RunActiveCampaignsJob < ApplicationJob
  queue_as :critical

  def perform
    Rails.logger.info("Run RunActiveCampaignsJob")
    Campaign.running.each do |campaign|
      next unless campaign.matching_algo_v2?
      RunCampaignJob.perform_later(campaign.id)
      NotifyMatchesBySmsJob.perform_later(campaign.id)
    end
  end
end
