FactoryBot.define do
  sequence(:birthdate) { Faker::Date.between(from: 100.years.ago, to: 10.years.ago) }
  sequence(:company_name) { Faker::Company.name }
  sequence(:description) { Faker::Lorem.paragraph(sentence_count: 2) }
  sequence(:firstname) { Faker::Name.first_name }
  sequence(:french_address) { Faker::Address.country_by_code(code: "FR") }
  sequence(:lastname) { Faker::Name.last_name }
  sequence(:lat) { Faker::Address.latitude }
  sequence(:lon) { Faker::Address.longitude }
  sequence(:name) { Faker::Name.name }
  sequence(:password) { "snipe.HACKSAW.fish" } # make sure password is valid
  sequence(:french_phone_number) do
    # Faker generates cell phones that are not valid
    # because not yet attributed
    # (Example : 0729999999 and lower are not attributed, 0730000000 and higher are)
    # We're looping until Faker generates a valid number
    phone_number = nil
    loop do
      phone_number = Faker::PhoneNumber.cell_phone
      if phone_number.gsub(/\s/, "").length == 9 && phone_number[0] != "0"
        phone_number = "0#{phone_number}"
      end
      break if Phonelib.valid?(phone_number)
    end
    phone_number
  end
  sequence(:unique_email) { Faker::Internet.unique.email(domain: "covidliste.com") }
end
