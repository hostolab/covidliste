class AnonymizeConfirmedMatchedUsersJob < ActiveJob::Base
  queue_as :default

  def perform
    users_to_anonymize.map(&:anonymize!)
  end

  private

  def users_to_anonymize
    last_week = Date.today - 1.week

    puts Match.joins("JOIN users ON matches.user_id = users.id")
      .where.not(confirmed_at: nil)
      .where(created_at: (last_week...Date.today))
      .where("users.anonymized_at": nil)
      .select("users.*").to_sql
  end
end

Sidekiq::Cron::Job.create(
  name: "Anonymize all confirmed matched users from the days before",
  cron: "0 3 * * *",
  class: "AnonymizeConfirmedMatchedUsersJob"
)
