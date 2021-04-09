class PushNewVaccinationCenterToSlackJob < ApplicationJob
  queue_as :critical

  SLACK_CHANNEL = "nouveau-centre".freeze

  def perform(vaccination_center)
    @vaccination_center = vaccination_center

    text = "Un nouveau centre vient d’être créé #{creator} :point_right: #{cta}"
    attachments = [
      {
        color: "",
        fields: [
          {
            title: "Nom",
            value: @vaccination_center.name,
            short: true
          },
          {
            title: "Type",
            value: @vaccination_center.kind,
            short: true
          },
          {
            title: "Description",
            value: @vaccination_center.description
          },
          {
            title: "Adresse",
            value: @vaccination_center.address
          }
        ]
      }
    ].to_json

    SlackNotifierJob.perform_later(SLACK_CHANNEL, text, attachments)
  end

  private

  def cta
    "<#{Rails.application.routes.url_helpers.admin_vaccination_center_url(@vaccination_center)}|Aller à la validation>"
  end

  def creator
    if @vaccination_center.partners.none?
      "par un admin"
    else
      "par #{@vaccination_center.partners.first.name}"
    end
  end
end
