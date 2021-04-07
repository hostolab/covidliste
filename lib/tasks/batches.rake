namespace :batches do
  desc "Creates a batch, matches, and sends them an text"
  task :create_and_print_batch, [:campaign_id, :batch_duration_minutes, :batch_size] => [:environment] do |t, args|
    # Finding campaign
    puts "Campaign ##{args[:campaign_id]}"
    puts "Batch duration: #{args[:batch_duration_minutes]} min"
    puts "Batch size: #{args[:batch_size]}"
    campaign = Campaign.find_by(id: args[:campaign_id])
    puts "Campaign not found" and return unless campaign

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
    users = User
            .joins("LEFT JOIN matches ON matches.id = users.id AND matches.sent_at > now()::date")
            .where("matches.id IS NULL AND SQRT(((? - lat)*110.574)^2 + ((? - lon)*111.320*COS(lat::float*3.14159/180))^2) < ?", batch.vaccination_center.lat, batch.vaccination_center.lon, campaign.max_distance_in_meters / 1000)
            .order(id: :asc)
            .limit(batch.size).all
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

    # Sending email
    puts "Let's send them email"
    matches.each do |match|
      match.update(expires_at: Time.now.utc + match.campaign_batch.duration_in_minutes)
      Mailer.with(match: match, token: match.match_confirmation_token).match_confirmation_instructions
      match.update(sent_at: Time.now.utc)
      puts "Email sent to match #{match.id}"
    end

    # Sending sms
  end
end
