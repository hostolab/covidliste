class PushNewCampaignToSlackJob < ApplicationJob
  queue_as :critical

  SLACK_CHANNEL = "nouvelle-campagne".freeze

  def perform(campaign_id)
    campaign = Campaign.find_by(id: campaign_id)
    return if campaign.blank?

    text = "Un nouvelle campagne vient d’être lancée#{creator(campaign.partner)}."

    attachments = [
      {
        color: "",
        fields: [
          {
            title: "Doses disponibles",
            value: campaign.available_doses,
            short: true
          },
          {
            title: "Vaccin",
            value: campaign.vaccine_type,
            short: true
          },
          {
            title: "Âge",
            value: "#{campaign.min_age} - #{campaign.max_age} ans",
            short: true
          },
          {
            title: "Distance",
            value: "#{(campaign.max_distance_in_meters / 1000.0).round(1)} km",
            short: true
          },
          {
            title: "Centre",
            value: campaign.vaccination_center.name,
            short: true
          },
          {
            title: "Type",
            value: campaign.vaccination_center.kind,
            short: true
          },
          {
            title: "Adresse",
            value: campaign.vaccination_center.address
          },
          {
            title: "Informations",
            value: campaign.extra_info
          },
          {
            title: "Horaires",
            value: "#{campaign.starts_at.strftime("%Hh%M")} - #{campaign.ends_at.strftime("%Hh%M")}",
            short: true
          }
        ]
      }
    ].to_json

    SlackNotifierJob.perform_later(SLACK_CHANNEL, text, attachments)
  end

  private

  def creator(partner)
    " par #{partner.name}" if partner.present?
  end
end
