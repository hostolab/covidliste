require "rails_helper"

RSpec.describe SeoPage, type: :model do
  let(:seo_page) { build(:seo_page) }

  describe "Fields validation" do
    it "has a valid factory" do
      expect(seo_page).to be_valid
    end
  end
end
