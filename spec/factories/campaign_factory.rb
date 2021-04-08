FactoryBot.define do
  factory :campaign do
    association :vaccination_center
    association :partner

    available_doses { 10 }
    starts_at { Time.zone.now }
    ends_at { starts_at + 10.minutes }
    min_age { 18 }
    max_age { 80 }
    max_distance_in_meters { 5_000 }
    vaccine_type { Vaccine::Brands::ALL.sample }

    trait :from_paris do
      association :vaccination_center, :from_paris
    end

    trait :from_lyon do
      association :vaccination_center, :from_lyon
    end
  end
end
