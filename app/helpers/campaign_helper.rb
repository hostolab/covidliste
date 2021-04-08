module CampaignHelper
  def french_status(campaign)
    return "En cours" if campaign.running?
    return "Terminée" if campaign.completed?
    return "Annulée" if campaign.canceled?

    raise NotImplementedError, "Please add a french translation for #{campaign.status}"
  end
end
