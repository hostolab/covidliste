class SendConfirmedMatchEmailJob < ApplicationJob
  queue_as :mailers

  def perform(match_id)
    match = Match.find(match_id)

    return if match.confirmed_mail_sent_at.present?
    MatchMailer.with(match: match).send_confirmed_match_details.deliver_now
    match.update(confirmed_mail_sent_at: Time.now.utc)
  end
end
