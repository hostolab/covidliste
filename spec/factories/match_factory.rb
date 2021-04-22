FactoryBot.define do
  factory :match do
    association :user
    association :campaign
    association :campaign_batch
    association :vaccination_center

    trait :confirmed do
      firstname { generate(:firstname) }
      lastname { generate(:lastname) }
      confirmed_at { Time.zone.now }
      expires_at { 10.minutes.ago }
    end

    trait :available do
      firstname { nil }
      lastname { nil }
      confirmed_at { nil }
      expires_at { 10.minutes.since }
    end

    trait :expired do
      firstname { nil }
      lastname { nil }
      confirmed_at { nil }
      expires_at { 10.minutes.ago }
    end
  end
end
