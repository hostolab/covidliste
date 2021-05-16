require "rails_helper"

RSpec.describe NoUrlValidator do
  subject do
    Class.new do
      include ActiveModel::Validations

      attr_accessor :content

      validates :content, no_url: true
    end.new
  end

  context "when content contains an URL" do
    it "is invalid" do
      subject.content = "This contains a URL https://www.covidliste.com/"

      expect(subject).to be_invalid
    end
  end

  context "when content does not contain an URL" do
    it "is valid" do
      subject.content = "This does not contain a URL"

      expect(subject).to be_valid
    end
  end
end
