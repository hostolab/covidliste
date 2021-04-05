FactoryBot.define do
  factory :user do
    birthdate { "1993-11-01" }
    password { "test_password" }
    address { "12 rue Larue, Lyon" }
    lat { 48.0 }
    lon { 2.0 }
    toc { true }
    firstname { "fist_name" }
    lastname { "last_name" }
    phone_number { "33611223344" }
    email { "test@covidliste.com" }
  end
end
