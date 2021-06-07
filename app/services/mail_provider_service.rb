require "sib-api-v3-sdk"

class MailProviderService
  attr_reader :pm_api_instance
  attr_reader :sib_api_instance

  def find_mails(email)
    sib_find_mails(email)
  end

  def sib_find_mails(email)
    sib_api_instance = SibApiV3Sdk::TransactionalEmailsApi.new
    opts = {
      limit: 50,
      offset: 0,
      days: 30,
      email: email,
      sort: "desc"
    }
    sib_api_instance.get_email_event_report(opts)
  end

  def pm_find_mails(email)
    pm_api_instance = ::PostmarkClient
    opts = {
      count: 50,
      offset: 0,
      fromdate: 30.days.ago,
      recipient: email
    }
    pm_api_instance.get_messages(opts)
  end
end
