FactoryBot.define do
  factory :slot_alert do
    association :user
    association :vmd_slot
    sent_at { nil }
    clicked_at { nil }
    refused_at { nil }
    settings { {} }
  end
end
