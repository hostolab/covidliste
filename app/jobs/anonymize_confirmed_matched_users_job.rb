class AnonymizeConfirmedMatchedUsersJob < ActiveJob::Base
  queue_as :default

  def perform
    users_to_anonymize.map(&:anonymize!)
  end

  private

  def users_to_anonymize
    two_weeks_ago = Date.today - 2.weeks
    last_week = Date.today - 1.week

    User.distinct
      .joins("JOIN matches ON matches.user_id = users.id")
      .where.not("matches.confirmed_at": nil)
      .where("matches.created_at": (two_weeks_ago..last_week))
      .where(anonymized_at: nil)
  end
end

Sidekiq::Cron::Job.create(
  name: "Anonymize all users with confirmed match from 7 days ago",
  cron: "0 3 * * *",
  class: "AnonymizeConfirmedMatchedUsersJob"
)
