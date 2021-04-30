class PushNewCampaignToSlackJob < ApplicationJob
  queue_as :critical

  SLACK_CHANNEL = "nouvelle-campagne".freeze

  def perform(campaign_id)
    campaign = Campaign.find(campaign_id)

    main_fields = [
      {
        "type": "mrkdwn",
        "text": "*Doses:*\n#{campaign.vaccine_type.capitalize} x#{campaign.available_doses}"
      },
      {
        "type": "mrkdwn",
        "text": "*Critères:*\n#{campaign.min_age} - #{campaign.max_age} ans, #{(campaign.max_distance_in_meters / 1000.0).round(1)} km"
      },
      {
        "type": "mrkdwn",
        "text": "*Établissement:*\n #{link(campaign.vaccination_center, "#{campaign.vaccination_center.name} ##{campaign.vaccination_center.id}")}"
      },
      {
        "type": "mrkdwn",
        "text": "*Horaires:*\n#{campaign.starts_at.strftime("%Hh%M")} - #{campaign.ends_at.strftime("%Hh%M")}"
      }
    ]

    context = [
      {
        "type": "mrkdwn",
        "text": "📍 #{campaign.vaccination_center.address}"
      }
    ]

    if campaign.extra_info
      context.append({
        "type": "mrkdwn",
        "text": "ℹ️ #{campaign.extra_info}"
      })
    end

    blocks = [
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "Une campagne vient d'être lancée#{creator(campaign.partner)}."
        }
      },
      {
        "type": "section",
        "fields": main_fields
      },
      {
        "type": "context",
        "elements": context
      }
    ]

    if campaign.vaccination_center.zipcode.nil?
      blocks.append({
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": "⚠️ Adresse du centre mal géocodée",
          "emoji": true
        }
      }, {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "Nous n'avons pas pu faire correspondre l'addresse à un code postal, pour éviter les erreurs de match. Vous devriez pouvoir réparer ça en reprécisant l'adresse du centre. Contactez Maxence Aici pour plus d'infos."
        }
      })
    end

    SlackNotifierJob.perform_later(SLACK_CHANNEL, nil, nil, blocks)
  end

  private

  def creator(partner)
    " par #{partner.name}" if partner.present?
  end

  def link(vaccination_center, text)
    "<#{Rails.application.routes.url_helpers.admin_vaccination_center_url(vaccination_center)}|#{text}>"
  end
end
