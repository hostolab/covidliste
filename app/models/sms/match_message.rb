class Sms::MatchMessage
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
    "Bonne nouvelle, une dose de vaccin vient de se libérer près de chez vous. Réservez-la vite sur : #{cta_url}"
  end

  def cta_url
    Rails.application.routes.url_helpers.match_url(match_confirmation_token: @match.match_confirmation_token, source: "sms")
  end
end
