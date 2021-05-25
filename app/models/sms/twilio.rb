class Sms::Twilio
  def initialize(match_message)
    @match_message = match_message
  end

  def self.to_enum_value
    Match.sms_providers[:twilio]
  end

  def send
    client = Twilio::REST::Client.new
    message = client.messages.create(from: @match_message.from, to: @match_message.to, body: @match_message.body)
    message.sid
  rescue Twilio::REST::TwilioError => e
    Rails.logger.info("[SmsTwilio] error #{e.message}")
    raise Sms::TwilioError, e.message
  end
end
