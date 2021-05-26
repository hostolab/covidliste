class Sms::SendInBlue
  def initialize(match_message)
    @match_message = match_message
  end

  def self.to_enum_value
    Match.sms_providers[:sendinblue]
  end

  def send_message
    client = SibApiV3Sdk::TransactionalSMSApi.new
    message = client.send_transac_sms(sender: @match_message.from, recipient: @match_message.to, content: @match_message.body)
    message.message_id
  end
end
