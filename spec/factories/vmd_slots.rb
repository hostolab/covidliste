FactoryBot.define do
  factory :vmd_slot do
    name { "Centre de Vaccination de Paris" }
    url { "https://www.doctolib.fr/" }
    address { "100 Avenue de la libérté, 75000 Paris" }
    latitude { 1.5 }
    longitude { 1.5 }
    city { "Paris" }
    department { "75" }
    next_rdv { "2021-05-08 11:12:06" }
    platform { "Doctolib" }
    center_type { "Centre" }
    slots_count { 40 }
    center_id { Faker::Company.name }
    last_updated_at { "2021-05-08 11:12:06" }
    slots_0_days { 10 }
    slots_1_days { 10 }
    slots_2_days { 10 }
    slots_7_days { 10 }
    slots_28_days { 10 }
    slots_49_days { 10 }
    astrazeneca { false }
    pfizer { true }
    moderna { false }
    janssen { false }
  end
end
