namespace :populate do
  desc "Generate fake users"
  task users: :environment do
    $stdout.flush
    puts "How many users do you want? (~1s / user)"
    print "> "
    count = $stdin.gets.chomp.to_i
    puts "Generating #{count} users..."
    count.times do |i|
      user = FactoryBot.create(:user, i.odd? ? :from_paris : :from_lyon)
      puts "#{i + 1}\t #{user.email}, #{user.age} ans - #{user.address} (#{user.lat}, #{user.lon})"
    end
    puts "Done."
  end

  desc "Create a new validated Vaccination center with a new partner"
  task create_vaccination_center_with_partner_and_validate: :environment do
    password = FactoryBot.generate(:password)
    partner = FactoryBot.create(:partner, :skip_validate, password: password) # skip_validate we don't want MX validations for email field
    vaccination_center = FactoryBot.create(:vaccination_center, :confirmed, (rand.to_i % 2) == 0 ? :from_lyon : :from_paris, pfizer: true)
    vaccination_center.partners << partner

    puts "Connexion à '#{vaccination_center.name}' avec le compte professionnel de santé assurant la vaccination : #{partner.email} / #{partner.password}"
  end
end
