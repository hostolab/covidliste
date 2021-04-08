class SendMatchEmailJob < ApplicationJob
  # TODO: Define retry_on policy: https://edgeapi.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on# TODO: # TODO: Define retry_on policy: https://edgeapi.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
  queue_as :critical

  def perform(match)
    return if match.mail_sent_at.present?

    match.update(expires_at: Time.now.utc + match.campaign_batch.duration_in_minutes.minutes) if match.expires_at.nil?

    MatchMailer.with(match: match).match_confirmation_instructions.deliver_now
    match.update(mail_sent_at: Time.now.utc)
  end
end
