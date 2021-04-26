class SendMatchSmsJob < ApplicationJob
  # TODO: Define retry_on policy: https://edgeapi.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
  queue_as :critical

  def perform(match)
    return if match.user.nil? ||
      match.user.phone_number.blank? ||
      match.sms_sent_at.present? || match.expired?

    client = Twilio::REST::Client.new
    client.messages.create(
      from: "COVIDLISTE",
      to: match.user.phone_number,
      body: "Un vaccin est disponible près de chez vous. Pour le réserver, suivez les instructions avant #{match.expires_at.strftime("%Hh%M")} : #{cta_url(match)}"
    )
    match.update(sms_sent_at: Time.now.utc)
  end

  private

  def cta_url(match)
    Rails.application.routes.url_helpers.match_url(match_confirmation_token: match.match_confirmation_token, source: "sms")
  end
end
