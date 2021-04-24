class SendMatchEmailJob < ApplicationJob
  # TODO: Define retry_on policy: https://edgeapi.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on# TODO: # TODO: Define retry_on policy: https://edgeapi.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
  queue_as :critical

  def perform(match)
    return if match.mail_sent_at.present? || match.expired?

    match.set_expiration!

    MatchMailer.match_confirmation_instructions(match).deliver_now
    match.update(mail_sent_at: Time.now.utc)
  end
end
