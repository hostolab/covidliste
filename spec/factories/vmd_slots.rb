FactoryBot.define do
  factory :vmd_slot do
    name { "MyString" }
    url { "MyString" }
    latitude { 1.5 }
    longitude { 1.5 }
    city { "MyString" }
    department { "MyString" }
    next_rdv { "2021-05-08 11:12:06" }
    platform { "MyString" }
    center_type { "MyString" }
    slots_count { 1 }
    center_id { "MyString" }
    last_updated_at { "2021-05-08 11:12:06" }
    slots_0_days { 1 }
    slots_1_days { 1 }
    slots_2_days { 1 }
    slots_7_days { 1 }
    slots_28_days { 1 }
    slots_49_days { 1 }
    astrazenca { false }
    pfizer { false }
    moderna { false }
    janssen { false }
  end
end
