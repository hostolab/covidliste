FactoryBot.define do
  factory :partner do
    email { generate(:unique_email) }
    name { generate(:name) }
    phone_number { "0606060606" }
    password { generate(:password) }
    statement { true }

    confirmed_at { Time.zone.now }
  end
end
