class SendMatchEmailJob < ApplicationJob
  # TODO: Define retry_on policy: https://edgeapi.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on# TODO: # TODO: Define retry_on policy: https://edgeapi.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
  queue_as :default

  def perform(match_id)
    match = Match.find(match_id)

    return if match.mail_sent_at.present? || match.expired? || match.refused?
    return if match.user.nil?
    return if match.user.anonymized_at?
    match.set_expiration!
    MatchMailer.with(match: match).match_confirmation_instructions.deliver_now
    match.update(mail_sent_at: Time.now.utc)
  end
end
