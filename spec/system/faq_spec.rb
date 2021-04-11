require "rails_helper"

RSpec.describe "FAQ Page", type: :system do
  it "loads properly" do
    visit "/faq"
    expect(page).to have_text("Foire aux questions")
  end
  it "knows the main email adress at least once" do
    visit "/faq"
    Capybara.ignore_hidden_elements = false # Email adress is hidden in accordion
    expect(page).to have_text("hello@covidliste.com")
  end
end
