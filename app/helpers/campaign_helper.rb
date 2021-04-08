module CampaignHelper
  def french_status(campaign)
    return "En cours" if campaign.running?
    return "Terminée" if campaign.completed?
    return "Annulée" if campaign.canceled?

    raise NotImplementedError, "Please add a french translation for #{campaign.status}"
  end

  def status_badge(campaign)
    return "badge-primary" if campaign.running?
    return "badge-secondary" if campaign.completed?
    return "badge-danger" if campaign.canceled?

    raise NotImplementedError, "Please add a badge for #{campaign.status}"
  end
end
