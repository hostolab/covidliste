FactoryBot.define do
  factory :campaign_batch do
    association :campaign
    association :vaccination_center
    association :partner

    size { 60 }
  end
end
