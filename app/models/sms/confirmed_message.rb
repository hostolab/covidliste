MAX_SMS_BODY_LENGTH = 160
# Unicode '…' (U+2026) is not supported by GSM charset
# https://www.textmagic.com/free-tools/unicode-detector
ELLIPSIS = "..."

class Sms::ConfirmedMessage
  def initialize(match)
    @match = match
  end

  def to
    @match.user.phone_number
  end

  def from
    "Covidliste"
  end

  def body
    ## body example
    #  RDV confirmé Dim 26/05 entre 12h50 - 13h15
    #  Pharmacie des Tournelles, Paris
    #  Plus d'info sur www.covidliste.com/match_id
    ##
    #  Max body size is 160
    #  In the example we have
    #  RDV confirmé 26/05 entre 12h50 - 13h15\n (time info, 39 chars, fixed)
    #  <Center name>, <City>                        (max X chars)
    #  Plus d'info www.domainname.com/match_id      (12 chars + link size)
    #  Truncate Center Name if needed
    body_time = "RDV confirmé #{I18n.l(@match.campaign.starts_at, format: "%a %d/%m %Hh%M")} - #{I18n.l(@match.campaign.ends_at, format: "%Hh%M")}\n"
    body_center_name = @match.vaccination_center.name
    body_city = ", #{@match.vaccination_center.city}\n"
    body_url = "Plus d'info sur #{cta_url}"

    fixed_body_length = body_time.length + body_city.length + body_url.length
    available_text_length = MAX_SMS_BODY_LENGTH - fixed_body_length
    if body_center_name.length > available_text_length
      body_center_name = body_center_name.slice(0, available_text_length - ELLIPSIS.length) + ELLIPSIS
    end

    body_time + body_center_name + body_city + body_url
  end

  def cta_url
    Rails.application.routes.url_helpers.match_url(match_confirmation_token: @match.match_confirmation_token, source: "sms_c")
  end
end
