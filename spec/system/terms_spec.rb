require "rails_helper"

RSpec.describe "Terms of Services - Volunteers", type: :system do
  before(:each) do
    visit "/cgu_volontaires"
  end

  it "loads properly" do
    expect(page).to have_text("CONDITIONS GÉNÉRALES D’UTILISATION – VOLONTAIRES NON VACCINÉS")
  end
end

RSpec.describe "Terms of Services - Pros", type: :system do
  before(:each) do
    visit "/cgu_pro"
  end

  it "loads properly" do
    expect(page).to have_text("CONDITIONS GÉNÉRALES D’UTILISATION – PROFESSIONNELS DE SANTÉ")
  end
end
