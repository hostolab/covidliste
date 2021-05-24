require "sib-api-v3-sdk"

class MailProviderService
  attr_reader :api_instance

  def find_mails(email)
    api_instance = SibApiV3Sdk::TransactionalEmailsApi.new
    opts = {
      limit: 50,
      offset: 0,
      days: 30,
      email: email,
      sort: "desc"
    }
    api_instance.get_email_event_report(opts)
  end
end
