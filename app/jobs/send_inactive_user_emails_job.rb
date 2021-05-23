class SendInactiveUserEmailsJob < ApplicationJob
  queue_as :low

  DEFAULT_MIN_REFUSED_MATCHES = 2 # At least two refused matches
  DEFAULT_AGE_RANGE = nil..nil # Covers all ages
  DEFAULT_SIGNED_IN_RANGE = nil..nil # Covers all dates

  def perform(*args)
    self.class.inactive_user_ids(*args).each do |user_id|
      UserMailer
        .with(user_id: user_id)
        .send_inactive_user_unsubscription_request
        .deliver_later
    end
  end

  def self.inactive_user_ids(min_refused_matches = DEFAULT_MIN_REFUSED_MATCHES, age_range = DEFAULT_AGE_RANGE, signed_in_date_range = DEFAULT_SIGNED_IN_RANGE)
    sql = <<~SQL.squish
      with target_users as (
        select id
        from users
        where anonymized_at is null
          and birthdate <= :max_birthdate
          and birthdate >= :min_birthdate
          and created_at <= :max_created_at
          and created_at >= :min_created_at
      ), match_stats_per_user as (
        select
          user_id
          , count(*) filter (where confirmed_at is not null) as confirmed_matches_count
          , count(*) filter (where refused_at is not null) as refused_matches_count
          , count(*) filter (where expires_at >= now() and confirmed_at is null and refused_at is null) as pending_matches_count
        from matches
        group by user_id
      )
      select u.id
      from target_users as u
      join match_stats_per_user as s
        on s.user_id = u.id
       and s.refused_matches_count >= :min_refused_matches
       and s.pending_matches_count = 0
       and s.confirmed_matches_count = 0
    SQL
    params = {
      min_refused_matches: min_refused_matches,
      min_birthdate: (age_range.end || 200).years.ago.to_date,
      max_birthdate: (age_range.begin || 0).years.ago.to_date,
      min_created_at: signed_in_date_range.begin || 200.years.ago,
      max_created_at: signed_in_date_range.end || Date.current.end_of_day
    }
    User.connection.select_values(
      ActiveRecord::Base.send(:sanitize_sql_array, [sql, params])
    )
  end
end
