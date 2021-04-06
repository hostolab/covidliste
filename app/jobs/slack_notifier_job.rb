class SlackNotifierJob < ActiveJob::Base
  queue_as :default

  def perform(channel, text, json_attachments = nil)
    body = {
      channel: channel,
      text: text,
      attachments: json_attachments ? JSON.parse(json_attachments) : nil
    }.to_json

    headers = {
      "Content-Type": "application/json"
    }
    HTTParty.post(ENV["SLACK_INCOMING_WEBHOOK_URL"], body: body, headers: headers)
  end
end
