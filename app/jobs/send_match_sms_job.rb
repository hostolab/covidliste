class SendMatchSmsJob < ApplicationJob
  # TODO: Define retry_on policy: https://edgeapi.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
  queue_as :critical

  def perform(match)
    return if match.user.nil? ||
      match.user.phone_number.blank? ||
      match.sms_sent_at.present? || match.expired?

    match.set_expiration!

    begin
      client = Twilio::REST::Client.new
      client.messages.create(
        from: "COVIDLISTE",
        to: match.user.phone_number,
        body: "Bonne nouvelle, une dose de vaccin vient de se libérer près de chez vous. Réservez-la vite sur : #{cta_url(match)}"
      )
      match.update(sms_sent_at: Time.now.utc)
    rescue Twilio::REST::TwilioError => e
      Rails.logger.info("[SendMatchSmsJob] #{e.message}")
    end
  end

  private

  def cta_url(match)
    Rails.application.routes.url_helpers.match_url(match_confirmation_token: match.match_confirmation_token, source: "sms")
  end
end
