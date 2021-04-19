require "rails_helper"

RSpec.describe "Mentions Legales Page", type: :system do
  before(:each) do
    visit "/mentions_legales"
  end

  it "loads properly" do
    expect(page).to have_text("Mentions légales")
  end

  it "has Martin as publication director" do
    expect(page).to have_text("HOSTOLAB")
    expect(page.text).to match(/Directeur de la publication.*Martin DANIEL/)
  end

  it "has information about hosting" do
    expect(page).to have_text("SCALINGO SAS")
    expect(page).to have_text("hello@scalingo.com")
    expect(page).to have_text("15, avenue du Rhin - 67100 Strasbourg")
  end
end
