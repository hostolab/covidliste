FactoryBot.define do
  factory :user do
    transient do
      confirmed_matches_count { 0 }
      refused_matches_count { 0 }
      unanswered_matches_count { 0 }
      pending_matches_count { 0 }
    end

    address { generate(:french_address) }
    lat { 48.1 }
    lon { 2.3 }
    birthdate { generate(:birthdate) }
    email { generate(:unique_email) }
    firstname { generate(:firstname) }
    lastname { generate(:lastname) }
    phone_number { "0606060606" }

    confirmed_at { Time.zone.now }

    statement { true }
    toc { true }

    trait :from_paris do
      address { "21 Rue Bergère 75009 Paris France" }
      lat { "48.87242501471677" }
      lon { "2.344941896580627" }
    end

    trait :from_lyon do
      address { "7 Rue Auguste Comte 69002 Lyon France" }
      lat { "45.75620064462772" }
      lon { "4.8319385046869945" }
    end

    trait :admin do
      after(:create) do |user|
        user.add_role(:admin)
      end
    end

    trait :super_admin do
      after(:create) do |user|
        user.add_role(:super_admin)
      end
    end

    trait :support_member do
      after(:create) do |user|
        user.add_role(:support_member)
      end
    end

    after(:create) do |user, evaluator|
      create_list(:match, evaluator.confirmed_matches_count, :confirmed, user: user)
      create_list(:match, evaluator.refused_matches_count, :refused, user: user)
      create_list(:match, evaluator.unanswered_matches_count, :expired, user: user)
      create_list(:match, evaluator.pending_matches_count, :pending, user: user)
    end
  end
end
