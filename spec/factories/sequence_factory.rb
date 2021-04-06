FactoryBot.define do
  sequence(:birthdate)           { Faker::Date.between(from: 100.years.ago, to: 10.years.ago) }
  sequence(:company_name)        { Faker::Company.name }
  sequence(:description)         { Faker::Lorem.paragraph(sentence_count: 2) }
  sequence(:firstname)           { Faker::Name.first_name  }
  sequence(:french_address)      { Faker::Address.country_by_code(code: 'FR') }
  sequence(:lastname)            { Faker::Name.last_name }
  sequence(:lat)                 { Faker::Address.latitude }
  sequence(:lon)                 { Faker::Address.longitude }
  sequence(:name)                { Faker::Name.name }
  sequence(:password)            { Faker::Lorem.characters(number: 10) }
  sequence(:french_phone_number) { Faker::PhoneNumber.phone_number }
  sequence(:unique_email)        { Faker::Internet.unique.email(domain: 'covidliste.com') }
end
