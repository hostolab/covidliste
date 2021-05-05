namespace :batches do
  desc "Creates a batch, matches, and sends them an text"
  task :create, [:campaign_id, :batch_size] => [:environment] do |t, args|
    campaign = Campaign.find(args[:campaign_id])
    puts "Campaign : #{campaign.name}"

    # Looking for users to match
    users = campaign.reachable_users_query(limit: args[:batch_size]).all
    puts "#{users.size} users found"

    # Creating the matches
    puts "Let's create matches"
    matches = []
    users.each do |user|
      matches << Match.create(
        campaign: campaign,
        vaccination_center: campaign.vaccination_center,
        user: user
      )
    end
    puts "#{matches.size} matches created"
  end
end
