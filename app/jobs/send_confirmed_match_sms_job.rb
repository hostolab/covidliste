MAX_SMS_BODY_LENGTH = 160
# Unicode '…' (U+2026) is not supported by GSM charset
# https://www.textmagic.com/free-tools/unicode-detector
ELLIPSIS = "..."

class SendConfirmedMatchSmsJob < ApplicationJob
  queue_as :mailers

  def perform(match_id)
    match = Match.find(match_id)

    return if match.user.nil? ||
      match.user.phone_number.blank? ||
      match.confirmed_sms_sent_at.present?

    begin
      provider = Flipper.enabled?(:sendinblue, match) ? "sendinblue" : "twilio"
      sms_provider_id = send_with_provider(match, provider)
      match.update(confirmed_sms_sent_at: Time.now.utc, confirm_sms_provider: provider, confirm_sms_provider_id: sms_provider_id)
    rescue => e
      Rails.logger.info("[SendConfirmedMatchSmsJob][#{provider}] error #{e.message}")
      if Rails.env.development?
        puts "[SendConfirmedMatchSmsJob][#{provider}] error #{e.message}"
      end
    end

    def cta_url(match)
      Rails.application.routes.url_helpers.match_url(match_confirmation_token: match.match_confirmation_token, source: "sms_c")
    end
  end

  private

  def send_with_provider(match, provider)
    from = "Covidliste"
    to = match.user.phone_number

    body = create_sms_body(match)

    return send_with_twilio(from, to, body) if provider == "twilio"
    return send_with_sendinblue(from, to, body) if provider == "sendinblue"
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

  def create_sms_body(match)
    ## body example
    #  RDV confirmé Dim 26/05 entre 12h50 - 13h15
    #  Pharmacie des Tournelles, Paris
    #  Plus d'info sur www.covidliste.com/match_id
    ##
    #  Max body size is 160
    #  In the example we have
    #  RDV confirmé Dim 26/05 entre 12h50 - 13h15\n (time info, 42 chars, fixed)
    #  <Center name>, <City>                        (max X chars)
    #  Plus d'info www.domainname.com/match_id      (12 chars + link size)
    #  Truncate Center Name if needed
    body_time = "RDV confirmé #{match.campaign.starts_at.strftime("%a %d/%m")} #{match.campaign.starts_at.strftime("%Hh%M")} - #{match.campaign.ends_at.strftime("%Hh%M")}\n"
    body_center_name = match.vaccination_center.name
    body_city = ", #{match.vaccination_center.city}\n"
    body_url = "Plus d'info sur: #{cta_url(match)}"

    fixed_body_length = body_time.length + body_city.length + body_url.length
    available_text_length = MAX_SMS_BODY_LENGTH - fixed_body_length
    if body_center_name.length > available_text_length
      body_center_name = body_center_name.slice(0, available_text_length - ELLIPSIS.length) + ELLIPSIS
    end

    body_time + body_center_name + body_city + body_url
  end
end
