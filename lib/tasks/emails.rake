namespace :emails do
  desc "Send inactive users email to ask them to delete their profile"
  task inactive_users: :environment do |_t, args|
    tz = ActiveSupport::TimeZone["Europe/Paris"]

    min_unanswered_matches = ENV["INACTIVE_USERS_MIN_REFUSED_MATCHES"]&.to_i || 2

    min_age_range = ENV["INACTIVE_USERS_MIN_AGE_RANGE"]&.to_i || 0
    max_age_range = ENV["INACTIVE_USERS_MAX_AGE_RANGE"]&.to_i || 200
    age_range = min_age_range..max_age_range

    min_signed_up_date_range = ENV["INACTIVE_USERS_MIN_SIGN_UP_DATE_RANGE"].try { |dt| tz.parse(dt) } || 200.years.ago
    max_signed_up_date_range = ENV["INACTIVE_USERS_MAX_SIGN_UP_DATE_RANGE"].try { |dt| tz.parse(dt) } || Date.current.end_of_day
    signed_up_date_range = min_signed_up_date_range..max_signed_up_date_range

    puts "The following filter will apply:"
    puts "- Refused Matches >= #{min_unanswered_matches}"
    puts "- #{min_age_range} <= Age <= #{max_age_range}"
    puts "- #{min_signed_up_date_range} <= Sign-up Date <= #{max_signed_up_date_range}"
    puts ""
    puts "Number of emails to send: ##{SendInactiveUserEmailsJob.inactive_user_ids(min_unanswered_matches, age_range, signed_up_date_range).size}"
    puts ""

    if ENV["NO_HELP"].nil?
      puts "To customize this, use environment variables:"
      puts "- INACTIVE_USERS_MIN_REFUSED_MATCHES: int default 2"
      puts "- INACTIVE_USERS_MIN_AGE_RANGE:          integer;  default: 0"
      puts "- INACTIVE_USERS_MAX_AGE_RANGE:          integer;  default: 200"
      puts "- INACTIVE_USERS_MIN_SIGN_UP_DATE_RANGE: datetime; default: 200 years ago; format: YYYY-MM-DD hh:mm:ss"
      puts "- INACTIVE_USERS_MAX_SIGN_UP_DATE_RANGE: datetime; default: end of today;  format: YYYY-MM-DD hh:mm:ss"
      puts ""
    end

    if ENV["NO_PROMPT"].nil?
      puts "Is that okay? Enter to continue / Ctrl + C to abort"
      puts ">"
      gets
    end

    SendInactiveUserEmailsJob.perform_now(min_unanswered_matches, age_range, signed_up_date_range)

    puts "Emails are enqueued!"
  end

  desc "Delete inactive users and email them to tell them"
  task delete_inactive_users_now: :environment do |_t, args|
    tz = ActiveSupport::TimeZone["Europe/Paris"]

    min_unanswered_matches = ENV["INACTIVE_USERS_MIN_REFUSED_MATCHES"]&.to_i || 10
    batch_size = ENV["INACTIVE_USERS_BATCH_SIZE"]&.to_i || 1000000

    min_age_range = ENV["INACTIVE_USERS_MIN_AGE_RANGE"]&.to_i || 0
    max_age_range = ENV["INACTIVE_USERS_MAX_AGE_RANGE"]&.to_i || 200
    age_range = min_age_range..max_age_range

    min_signed_up_date_range = ENV["INACTIVE_USERS_MIN_SIGN_UP_DATE_RANGE"].try { |dt| tz.parse(dt) } || 200.years.ago
    max_signed_up_date_range = ENV["INACTIVE_USERS_MAX_SIGN_UP_DATE_RANGE"].try { |dt| tz.parse(dt) } || 3.weeks.ago
    signed_up_date_range = min_signed_up_date_range..max_signed_up_date_range

    puts "The following filters will apply:"
    puts "- Refused/Unanswered Matches >= #{min_unanswered_matches}"
    puts "- #{min_age_range} <= Age <= #{max_age_range}"
    puts "- #{min_signed_up_date_range} <= Sign-up Date <= #{max_signed_up_date_range}"
    puts ""
    puts "Number of users to delete: ##{SendInactiveUserEmailsJob.inactive_user_ids(min_unanswered_matches, age_range, signed_up_date_range).size}"
    puts "This batch will be limited to ##{batch_size} users"
    puts ""

    if ENV["NO_HELP"].nil?
      puts "To customize this, use environment variables:"
      puts "- INACTIVE_USERS_MIN_REFUSED_MATCHES: int default 10"
      puts "- INACTIVE_USERS_BATCH_SIZE: int default 1000000"
      puts "- INACTIVE_USERS_MIN_AGE_RANGE:          integer;  default: 0"
      puts "- INACTIVE_USERS_MAX_AGE_RANGE:          integer;  default: 200"
      puts "- INACTIVE_USERS_MIN_SIGN_UP_DATE_RANGE: datetime; default: 200 years ago; format: YYYY-MM-DD hh:mm:ss"
      puts "- INACTIVE_USERS_MAX_SIGN_UP_DATE_RANGE: datetime; default: 3 weeks ago;  format: YYYY-MM-DD hh:mm:ss"
      puts ""
    end

    if ENV["NO_PROMPT"].nil?
      puts "Is that okay? Enter to continue / Ctrl + C to abort"
      puts ">"
      gets
    end

    user_ids_to_anonymize = SendInactiveUserEmailsJob.inactive_user_ids(min_unanswered_matches, age_range, signed_up_date_range)[0..(batch_size - 1)]
    puts user_ids_to_anonymize
    user_ids_to_anonymize.each do |user_id,|
      user_to_anonymize = User.find(user_id)
      if user_to_anonymize&.has_role?(:volunteer)
        puts "Skipping user ##{user_id}, because they're a volunteer"
        next
      end
      puts "Anonymizing user ##{user_id}"
      user_email = user_to_anonymize.email
      user_to_anonymize.anonymize!("delete_inactive_users_now")
      UserMailer.with(user_email: user_email).send_inactive_user_anonymization_notice.deliver_later
    end

    puts "Deletion done"
  end
end
