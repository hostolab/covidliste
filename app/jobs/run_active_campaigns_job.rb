class RunActiveCampaignsJob < ApplicationJob
  queue_as :critical

  def perform
    Rails.logger.info("Run RunActiveCampaignsJob")
    Campaign.running.each do |campaign|
      return unless campaign.matching_algo_v2?
      RunCampaignJob.perform_later(campaign)
      NotifyMatchesBySmsJob.perform_later(campaign)
    end
  end
end
