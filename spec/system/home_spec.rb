require "rails_helper"

RSpec.describe "Home Page", type: :system do
  it "loads properly" do
    visit "/"
    expect(page).to have_text("Un vaccin rapidement, sans chercher.")
  end
end
