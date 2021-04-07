namespace :populate do
  desc "Create a new validated Vaccination center with a new partner"
  task create_vaccination_center_with_partner_and_validate: :environment do
    partner = Partner.new(
      name: Faker::Name,
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
