class SlackNotifierJob < ActiveJob::Base
  queue_as :default

  def perform(channel, text, attachments)
    body = {
      channel: channel,
      text: text,
      attachments: attachments ? JSON.parse(attachments) : nil
    }.to_json

    response = HTTP \
      .headers("Content-Type": "application/json")
      .post(
        ENV["SLACK_INCOMING_WEBHOOK_URL"],
        body: body
      )
    puts response.to_s
  end
end
