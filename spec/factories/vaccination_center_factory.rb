FactoryBot.define do
  factory :vaccination_center do
    address { generate(:french_address) }
    description { generate(:description) }
    kind { VaccinationCenter::Kinds::ALL.sample }
    name { generate(:company_name) }
    phone_number { generate(:french_phone_number) }

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

    trait :confirmed do
      confirmed_at { Time.zone.now }
    end
  end
end
