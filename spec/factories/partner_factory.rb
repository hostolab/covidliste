FactoryBot.define do
  factory :partner do
    email { generate(:unique_email) }
    name { generate(:name) }
    phone_number { generate(:french_phone_number) }
    password { generate(:password) }
    statement { true }
    confirmed_at { Time.zone.now }

    trait :skip_validate do
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
