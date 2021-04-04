require "rails_helper"

RSpec.describe "Home page", type: :system do
  it "loads properly" do
    visit "/"
    expect(page).to have_text("Qu’est ce que Covidliste ?")
  end
end
