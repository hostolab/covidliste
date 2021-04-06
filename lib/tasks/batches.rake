namespace :batches do
  
  desc "Creates a batch, matches, and sends them an text"
  task :create_and_print_batch, [:campaign_id, :batch_duration_minutes, :batch_size] => [:environment] do |t, args|
      puts args[:campaign_id]
      puts args[:batch_duration_minutes]
      puts args[:batch_size]
      campaign = Campaign.find_by(id: args[:campaign_id])
      unless campaign
        puts "Campaign not found" and return
      end
      puts "Campaign : #{campaign.name}"

      batch = CampaignBatch.create!(campaign: campaign, vaccination_center: campaign.vaccination_center, size: args[:batch_size], duration_in_minutes: args[:batch_duration_minutes])
      puts "Batch #{batch.id} created"


      users = User
        .joins(:matches)
        .where("matches.id IS NULL AND matches.sent_at < now()::date")
        .near([batch.vaccination_center.lat, batch.vaccination_center.lon], campaign.max_distance_in_meters, unit: :m)
        .order(id: :asc)
        .limit(batch.size).to_sql
        # .all

        
        puts users
      # users.each do |user|
      #   puts user.id
      # end
    end
end
