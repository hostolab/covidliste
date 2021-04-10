class AnonymizeConfirmedMatchedUsersJob < ActiveJob::Base
  queue_as :default

  def perform
    users_to_anonymize.map(&:anonymize!)
  end

  private

  def users_to_anonymize
    a_month_ago = Date.today - 1.month
    three_days_ago = Date.today - 3.days

    User.distinct
      .joins("JOIN matches ON matches.user_id = users.id")
      .where.not("matches.confirmed_at": nil)
      .where("matches.created_at": (a_month_ago..three_days_ago))
      .where(anonymized_at: nil)
  end
end

Sidekiq::Cron::Job.create(
  name: "Anonymize all users with confirmed match from 3 days ago and more",
  cron: "0 3 * * *",
  class: "AnonymizeConfirmedMatchedUsersJob"
)
