require "rails_helper"

RSpec.describe "Users", type: :system do
  it "can sign up" do
    expect do
      visit "/"
      fill_in :user_firstname, with: Faker::Name.first_name
      fill_in :user_lastname, with: Faker::Name.last_name
      fill_in :user_address, with: Faker::Address.full_address
      fill_in :user_phone_number, with: Faker::PhoneNumber.cell_phone
      fill_in :user_email, with: "hello+#{(rand * 10000).to_i}@covidliste.com" # needs valid email here
      fill_in :user_password, with: Faker::Internet.password
      check :user_statement
      check :user_toc
      click_on "Je m’inscris"
    end.to change { User.count }.by(1)
  end
end
