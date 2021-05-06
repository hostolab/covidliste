class SendMatchSmsJob < ApplicationJob
  # TODO: Define retry_on policy: https://edgeapi.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
  queue_as :critical

  def perform(match_id)
    match = Match.find(match_id)

    return if match.user.nil? ||
      match.user.phone_number.blank? ||
      match.sms_sent_at.present? || match.expired?

    match.set_expiration!

    begin
      provider = Flipper.enabled?(:sendinblue, match) ? "sendinblue" : "twilio"
      sms_provider_id = send_with_provider(match, provider)
      match.update(sms_sent_at: Time.now.utc, sms_provider: provider, sms_provider_id: sms_provider_id)
    rescue => e
      Rails.logger.info("[SendMatchSmsJob][#{provider}] error #{e.message}")
      if Rails.env.development?
        puts "[SendMatchSmsJob][#{provider}] error #{e.message}"
      end
    end
  end

  private

  def send_with_provider(match, provider)
    from = "Covidliste"
    to = match.user.phone_number
    body = "Bonne nouvelle, une dose de vaccin vient de se libérer près de chez vous. Réservez-la vite sur : #{cta_url(match)}"
    if provider == "twilio"
      return send_with_twilio(from, to, body)
    end
    if provider == "sendinblue"
      return send_with_sendinblue(from, to, body)
    end
    raise ArgumentError, "Unknown provider", caller
  end

  def send_with_twilio(from, to, body)
    client = Twilio::REST::Client.new
    message = client.messages.create(from: from, to: to, body: body)
    message.sid
  end

  def send_with_sendinblue(from, to, body)
    client = SibApiV3Sdk::TransactionalSMSApi.new
    message = client.send_transac_sms(sender: from, recipient: to, content: body)
    message.message_id
  end

  def cta_url(match)
    Rails.application.routes.url_helpers.match_url(match_confirmation_token: match.match_confirmation_token, source: "sms")
  end
end
