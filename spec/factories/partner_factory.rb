FactoryBot.define do
  factory :partner do
    email { generate(:unique_email) }
    name { generate(:name) }
    phone_number { generate(:french_phone_number) }
    password { generate(:password) }

    confirmed_at { Time.zone.now }
  end
end
