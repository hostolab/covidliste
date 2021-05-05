class SlackNotifierJob < ApplicationJob
  queue_as :critical

  def perform(channel, text, json_attachments = nil, blocks = nil)
    body = {
      channel: Rails.env.production? ? channel : "test-dev",
      text: text,
      attachments: json_attachments ? JSON.parse(json_attachments) : nil,
      blocks: blocks
    }.to_json

    headers = {
      "Content-Type": "application/json"
    }
    HTTParty.post(ENV["SLACK_INCOMING_WEBHOOK_URL"], body: body, headers: headers)
  end
end
