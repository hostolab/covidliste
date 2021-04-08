FactoryBot.define do
  factory :match do
    association :user
    association :campaign
    association :campaign_batch
    association :vaccination_center

    trait :confirmed do
      confirmed_at { Time.zone.now }
    end
  end
end
