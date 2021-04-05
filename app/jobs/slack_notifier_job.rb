class SlackNotifierJob < ActiveJob::Base
  queue_as :default

  def perform(channel, text, blocks)
    body = {
      channel: channel,
      text: text,
      blocks: JSON.parse(blocks)
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
