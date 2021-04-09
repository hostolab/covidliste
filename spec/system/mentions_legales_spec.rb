require "rails_helper"

RSpec.describe "Mentions Legales Page", type: :system do
  it "loads properly" do
    visit "/mentions_legales"
    expect(page).to have_text("Mentions légales")
  end
  it "has Martin as publication director" do
    visit "/mentions_legales"
    expect(page).to have_text("Directeur de la publication (éditeur) : Martin DANIEL")
  end
  it "has information about hosting" do
    visit "/mentions_legales"
    expect(page.text).to match(/^.*hébergé par.* dont le siège social est sis.*SIRET.* [0-9]{14}.*$/)
  end
end
