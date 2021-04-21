require "rails_helper"

RSpec.describe "Cookies Page", type: :system do
  before(:each) do
    visit "/cookies"
  end

  it "loads properly" do
    expect(page.text).to match(/Politique de gestion des cookies/i)
  end

  it "mentions the session cookie" do
    expect(page).to have_text("_covidliste_session")
  end
end
