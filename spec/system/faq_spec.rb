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

  it "none should contain ', only ’" do
    FaqItem.all.each do |faq_item|
      expect(faq_item.title).not_to include("'")
      expect(faq_item.body).not_to include("'")
    end
  end
end

RSpec.describe "FAQ PRO Page", type: :system do
  it "loads properly" do
    visit "/partenaires/faq"
    expect(page).to have_text("Foire aux questions pour les professionnels de santé")
  end

  it "knows the partners email adress at least once" do
    visit "/partenaires/faq"
    Capybara.ignore_hidden_elements = false # Email adress is hidden in accordion
    expect(page).to have_text("partenaires@covidliste.com")
  end
end
