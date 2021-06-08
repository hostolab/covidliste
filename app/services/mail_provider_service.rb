require "sib-api-v3-sdk"

class MailProviderService
  attr_reader :pm_api_instance
  attr_reader :sib_api_instance

  def find_mails(email)
    pm_find_mails(email).merge(sib_find_mails(email))
  end

  def sib_find_mails(email)
    sib_api_instance = SibApiV3Sdk::TransactionalEmailsApi.new
    opts = {
      limit: 50,
      offset: 0,
      days: 10,
      email: email,
      sort: "desc"
    }
    @user_mails = {}
    sib_api_instance.get_email_event_report(opts).events.each do |event|
      unless @user_mails[event.message_id]
        @user_mails[event.message_id] = {
          provider: "SendInBlue",
          subject: event.subject,
          date: event.date.to_datetime.in_time_zone,
          from: event.from,
          to: event.email,
          state: event.event,
          events: []
        }
      end
      @user_mails[event.message_id][:events].push({
        date: event.date.to_datetime.in_time_zone,
        name: event.event,
        reason: event.reason
      })
    end
    @user_mails
  end

  def pm_find_mails(email)
    pm_api_instance = Postmark::ApiClient.new(Rails.configuration.postmark_api_key)
    opts = {
      count: 10,
      offset: 0,
      fromdate: 10.days.ago,
      recipient: email
    }
    messages = pm_api_instance.get_messages(opts)
    @user_mails = {}
    messages.each do |pm_message|
      message = pm_api_instance.get_message(pm_message[:message_id])
      @user_mails[message[:message_id]] = {
        provider: "Postmark",
        subject: message[:subject],
        date: message[:received_at].to_datetime.in_time_zone,
        from: message[:from],
        to: message[:recipients[0]],
        state: message[:status],
        events: []
      }
      message[:message_events].each do |event|
        delivery_message = begin
          event["Details"]["DeliveryMessage"].gsub(/'https?:\/\/.*'/, "<REDACTED>")
        rescue
          nil
        end
        summary = begin
          event["Details"]["Summary"].gsub(/'https?:\/\/.*'/, "<REDACTED>")
        rescue
          nil
        end
        if !summary && delivery_message
          summary = delivery_message
        end
        @user_mails[message[:message_id]][:events].push({
          date: event["ReceivedAt"].to_datetime.in_time_zone,
          name: event["Type"],
          reason: summary
        })
        @user_mails[message[:message_id]][:state] = event["Type"]
      end
      @user_mails[message[:message_id]][:events].push({
        date: message[:received_at].to_datetime.in_time_zone,
        name: message[:status],
        reason: nil
      })
    end
    @user_mails
  end
end
