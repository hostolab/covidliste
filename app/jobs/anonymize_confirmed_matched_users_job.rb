class AnonymizeConfirmedMatchedUsersJob < ActiveJob::Base
  queue_as :default

  DELAY_AFTER_MATCH_CONFIRMATION = 3.days

  def perform
    users_to_anonymize.find_each do |user_to_anonymize|
      user = user_to_anonymize.dup
      user_to_anonymize.anonymize!
      MatchMailer.with(user: user).send_anonymisation_notice.deliver_later
    end
  end

  private

  def users_to_anonymize
    a_month_ago = Date.today - 1.month
    three_days_ago = DELAY_AFTER_MATCH_CONFIRMATION.ago

    User.distinct
      .joins("JOIN matches ON matches.user_id = users.id")
      .where.not("matches.confirmed_at": nil)
      .where("matches.created_at": (a_month_ago..three_days_ago))
      .where(anonymized_at: nil)
  end
end
