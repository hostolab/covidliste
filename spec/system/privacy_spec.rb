require "rails_helper"

RSpec.describe "Privacy Page", type: :system do
  it "loads properly" do
    visit "/privacy"
    expect(page).to have_text("Protection des données")
  end
  it "has the ssi mail" do
    visit "/privacy"
    expect(page).to have_text("ssi@covidliste.com")
    end
  it "has the privacy mail" do
    visit "/privacy"
    expect(page).to have_text("privacy@covidliste.com")
  end
end