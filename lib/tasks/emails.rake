namespace :emails do
  desc "Send inactive users email to ask them to delete their profile"
  task inactive_users: :environment do |_t, args|
    tz = ActiveSupport::TimeZone["Europe/Paris"]

    min_refused_matches = ENV["MIN_REFUSED_MATCHES"]&.to_i || 2

    min_age_range = ENV["MIN_AGE_RANGE"]&.to_i || 0
    max_age_range = ENV["MAX_AGE_RANGE"]&.to_i || 200
    age_range = min_age_range..max_age_range

    min_signed_up_date_range = ENV["MIN_SIGN_UP_DATE_RANGE"].try { |dt| tz.parse(dt) } || 200.years.ago
    max_signed_up_date_range = ENV["MAX_SIGN_UP_DATE_RANGE"].try { |dt| tz.parse(dt) } || Date.current.end_of_day
    signed_up_date_range = min_signed_up_date_range..max_signed_up_date_range

    puts "The following filter will apply:"
    puts "- Refused Matches >= #{min_refused_matches}"
    puts "- #{min_age_range} <= Age <= #{max_age_range}"
    puts "- #{min_signed_up_date_range} <= Sign-up Date <= #{max_signed_up_date_range}"
    puts ""
    puts "Number of emails to send: ##{SendInactiveUserEmailsJob.inactive_user_ids(min_refused_matches, age_range, signed_up_date_range).size}"
    puts ""

    if ENV["NO_HELP"].nil?
      puts "To customize this, use environment variables:"
      puts "- MIN_REFUSED_MATCHES: int default 2"
      puts "- MIN_AGE_RANGE:          integer;  default: 0"
      puts "- MAX_AGE_RANGE:          integer;  default: 200"
      puts "- MIN_SIGN_UP_DATE_RANGE: datetime; default: 200 years ago; format: YYYY-MM-DD hh:mm:ss"
      puts "- MAX_SIGN_UP_DATE_RANGE: datetime; default: end of today;  format: YYYY-MM-DD hh:mm:ss"
      puts ""
    end

    if ENV["NO_PROMPT"].nil?
      puts "Is that okay? Enter to continue / Ctrl + C to abort"
      puts ">"
      gets
    end

    SendInactiveUserEmailsJob.perform_later(min_refused_matches, age_range, signed_up_date_range)

    puts "Emails are enqueued!"
  end
end
