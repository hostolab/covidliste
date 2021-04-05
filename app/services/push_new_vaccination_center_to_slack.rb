class PushNewVaccinationCenterToSlack
  def initialize(vaccination_center)
    @vaccination_center = vaccination_center
  end

  def call
    text = "Un nouveau centre vient d'être créé par *#{creator}* :point_right: #{cta}"
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
            title: "Addresse",
            value: @vaccination_center.address
          }
        ]
      }
    ].to_json
    SlackNotifierJob.perform_later(channel, text, attachments)
  end

  private

  def channel
    Rails.env.production? ? "nouveau-centre" : "test"
  end

  def cta
    "<#{Rails.application.routes.url_helpers.admin_vaccination_centers_url}|Aller à la validation>"
  end

  def creator
    @vaccination_center.partners.first.name
  end
end
