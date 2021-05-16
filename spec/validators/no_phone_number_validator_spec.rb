require "rails_helper"

RSpec.describe NoPhoneNumberValidator do
  subject do
    Class.new do
      include ActiveModel::Validations

      attr_accessor :content

      validates :content, no_phone_number: true
    end.new
  end

  context "when content contains an phone number" do
    it "is invalid" do
      contents = [
        "This contains a mobile phone number 06 06 06 06 06",
        "This contains a fixed line phone number 0478787878",
        "This contains a mobile phone with country code +33606060606",
        "This contains a fixed line phone number with country code +334 78 78 78 78"
      ]

      contents.each do |content|
        subject.content = content

        expect(subject).to be_invalid
      end
    end
  end

  context "when content does not contain a phone number" do
    it "is valid" do
      subject.content = "This does not contain a phone number"

      expect(subject).to be_valid
    end
  end
end
