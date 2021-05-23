FactoryBot.define do
  factory :match do
    association :user
    association :campaign
    association :vaccination_center

    trait :confirmed do
      confirmed_at { Time.zone.now }
    end

    trait :refused do
      refused_at { Time.zone.now }
    end

    trait :available do
      expires_at { 1.hours.from_now }
    end

    trait :pending do
      expires_at { 1.hours.from_now }
    end
  end
end
