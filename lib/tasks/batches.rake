namespace :batches do
  desc "Creates a batch, matches, and sends them an text"
  task :create, [:campaign_id, :batch_duration_minutes, :batch_size] => [:environment] do |t, args|
    # Finding campaign
    puts "Campaign ##{args[:campaign_id]}"
    puts "Batch duration: #{args[:batch_duration_minutes]} min"
    puts "Batch size: #{args[:batch_size]}"
    campaign = Campaign.find_by(id: args[:campaign_id])

    puts "Campaign : #{campaign.name}"

    # Creating a new batch
    puts "Let's create a batch"
    batch = CampaignBatch.create!(
      campaign: campaign,
      vaccination_center: campaign.vaccination_center,
      size: args[:batch_size],
      duration_in_minutes: args[:batch_duration_minutes]
    )
    puts "Batch #{batch.id} created"

    # Looking for users to match
    users = batch.vaccination_center.reachable_users_query(
      min_age: campaign.min_age,
      max_age: campaign.max_age,
      max_distance_in_meters: campaign.max_distance_in_meters,
      limit: batch.size
    ).all
    puts "#{users.size} users found"

    # Creating the matches
    puts "Let's create matches"
    matches = []
    users.each do |user|
      matches << Match.create(
        campaign: campaign,
        campaign_batch: batch,
        vaccination_center: campaign.vaccination_center,
        user: user
      )
    end
    puts "#{matches.size} matches created"
    puts "Batch #{batch.id} created"

    # Sending email + sms
  end

  desc "Sends mails/sms to matches of a batch"
  task :send, [:batch_id] => [:environment] do |t, args|
    batch = CampaignBatch.find(args[:batch_id])

    puts "Let's send them an email and an SMS"
    client = Twilio::REST::Client.new
    batch.matches.each do |match|
      next if match.sms_sent_at.present? || match.mail_sent_at.present?

      match.update(expires_at: Time.now.utc + match.campaign_batch.duration_in_minutes.minutes)

      begin
        MatchMailer.with(match: match, match_confirmation_token: match.match_confirmation_token).match_confirmation_instructions.deliver_now
        match.update(mail_sent_at: Time.now.utc)
      rescue => exception
        puts exception.class
        puts exception.message
        puts "Error sending email to match #{match.id}"
      end

      # User can ban nil or anonymized, so we check if phone_number is present? before trying to send SMS
      if match&.user&.phone_number.present?
        begin
          response = client.messages.create(
            from: "COVIDLISTE",
            to: match.user.phone_number,
            body: "Bonne nouvelle ! Un vaccin #{batch.campaign.vaccine_type} est disponible. Réservez-le avant #{match.expires_at.strftime("%Hh%M")} en cliquant ici : https://www.covidliste.com/matches/#{match.match_confirmation_token}"
          )
          puts response.body
          match.update(sms_sent_at: Time.now.utc)
        rescue => e
          puts e.class
          puts e.message
          puts "Error sending sms to match #{match.id}"
        end
      end
    end
    puts "Done !"
  end
end
