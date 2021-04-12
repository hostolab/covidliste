namespace :populate do
  desc "Generate fake users"
  task users: :environment do
    puts "How many users do you want? (~1s / user)"
    print "> "
    count = gets.chomp.to_i
    puts "Generating #{count} users..."
    count.times do |i|
      user = User.new(
        firstname: Faker::Name.first_name,
        lastname: Faker::Name.last_name,
        email: Faker::Internet.unique.email(domain: "covidliste.com"),
        birthdate: Faker::Date.between(from: 100.years.ago, to: 18.years.ago),
        address: Faker::Address.full_address,
        password: Faker::Internet.password,
        phone_number: Faker::PhoneNumber.cell_phone,
        toc: true,
        statement: true
      )
      user.skip_confirmation!
      user.save!
      user.update_columns(confirmed_at: Time.now.utc)
      GeocodeUserJob.perform_now(user.id)
      user.reload
      puts "#{i + 1}. #{user.full_name}, #{user.age} ans - #{user.address} (#{user.lat}, #{user.lon})"
    end
    puts "Done."
  end

  desc "Create a new validated Vaccination center with a new partner"
  task create_vaccination_center_with_partner_and_validate: :environment do
    partner = Partner.new(
      name: Faker::Name.name,
      email: Faker::Internet.email,
      phone_number: Faker::PhoneNumber.phone_number,
      password: Faker::Internet.password
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

    puts "Connexion à '#{vaccination_center.name}' avec le compte Partenaire : #{partner.email} / #{partner.password}"
  end
end
