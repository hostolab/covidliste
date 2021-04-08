FactoryBot.define do
  factory :user do
    address { generate(:french_address) }
    birthdate { generate(:birthdate) }
    email { generate(:unique_email) }
    firstname { generate(:firstname) }
    lastname { generate(:lastname) }
    password { generate(:password) }
    phone_number { generate(:french_phone_number) }

    confirmed_at { Time.zone.now }

    toc { true }

    trait :from_lyon do
      address { "21 Rue Bergère 75009 Paris" }
      lat { "48.87242501471677" }
      lon { "2.344941896580627" }
    end

    trait :from_paris do
      address { "7 Rue Auguste Comte 69002 Lyon" }
      lat { "45.75620064462772" }
      lon { "4.8319385046869945" }
    end
  end
end
