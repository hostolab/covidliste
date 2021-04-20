require "rails_helper"

RSpec.describe "Privacy Page for Volunteers", type: :system do
  before(:each) do
    visit "/privacy_volontaires"
  end

  it "loads properly" do
    expect(page).to have_text("Politique de protection des données personnelles - Volontaires non vaccinés")
  end

  it "has the ssi mail" do
    expect(page).to have_text("ssi@covidliste.com")
  end

  it "has the privacy mail" do
    expect(page).to have_text("privacy@covidliste.com")
  end
end

RSpec.describe "Privacy Page for Pros", type: :system do
  before(:each) do
    visit "/privacy_pro"
  end

  it "loads properly" do
    expect(page).to have_text("Politique de protection des données personnelles - Professionnels de santé")
  end

  it "has the privacy mail" do
    expect(page).to have_text("privacy@covidliste.com")
  end
end

RSpec.describe "Legacy /privacy route should redirect to /privacy_volontaires", type: :system do
  before(:each) do
    visit "/privacy"
  end

  it "loads the volunteers' privacy page" do
    expect(page).to have_text("Politique de protection des données personnelles - Volontaires non vaccinés")
  end
end
