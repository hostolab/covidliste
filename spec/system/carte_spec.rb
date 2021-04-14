require "rails_helper"

RSpec.describe "Carte Page", type: :system do
  let!(:vaccination_center) { create(:vaccination_center) }
  let(:user) { create(:user, :admin) }
  before { login_as(user) }

  it "loads properly" do
    visit "/carte"

    expect(page).to have_text("France métropolitaine")
    expect(page).to have_text("Guyanne")
    expect(page).to have_css("#map.mapboxgl-map")
  end
end
