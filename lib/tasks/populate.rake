namespace :populate do
  desc "Generate fake users"
  task users: :environment do
    puts "How many users do you want? (~1s / user)"
    print "> "
    count = gets.chomp.to_i
    puts "Generating #{count} users..."
    count.times do |i|
      user = User.new(
        email: Faker::Internet.unique.email(domain: "covidliste.com"),
        birthdate: Faker::Date.between(from: 100.years.ago, to: 18.years.ago),
        address: Faker::Address.full_address,
        phone_number: "+33601020304",
        toc: true,
        statement: true,
        lat: Faker::Address.latitude,
        lon: Faker::Address.longitude,
      )
      user.skip_confirmation!
      user.save!
      user.update_columns(confirmed_at: Time.now.utc)
      GeocodeResourceJob.perform_now(user)
      user.reload
      puts "#{i + 1}. #{user}, #{user.age} ans - #{user.address} (#{user.lat}, #{user.lon})"
    end
    puts "Done."
  end

  desc "Create a new validated Vaccination center with a new partner"
  task create_vaccination_center_with_partner_and_validate: :environment do
    partner = Partner.new(
      name: Faker::Name.name,
      email: Faker::Internet.email,
      phone_number: Faker::PhoneNumber.phone_number,
      password: "1G09_!9s08vUsa"
    )
    partner.save!(validate: false) # Bypass MX validation

    vaccination_center = VaccinationCenter.new(
      name: "#{Faker::TvShows::GameOfThrones.city} Center",
      description: Faker::Lorem.sentences.join(" "),
      address: Faker::Address.full_address,
      kind: VaccinationCenter::Kinds::ALL.sample,
      lat: 48.864716, # Paris
      lon: 2.349014,
      pfizer: true,
      phone_number: Faker::PhoneNumber.phone_number
    )
    vaccination_center.save!
    vaccination_center.update(confirmed_at: Time.now.utc)
    vaccination_center.partners << partner

    puts "Connexion à '#{vaccination_center.name}' avec le compte professionnel de santé assurant la vaccination : #{partner.email} / #{partner.password}"
  end
end
