require "rails_helper"

RSpec.describe PostalAddressValidator do
  subject do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :address
      validates :address, postal_address: {with_zipcode: true, message: "invalid_message"}
    end.new
  end

  context "when the postal address is valid" do
    let(:address) { generate(:french_address) }

    it "allows the input" do
      subject.address = address
      expect(subject).to be_valid
    end
  end

  context "when the postal address is invalid" do
    let(:invalid_message) { "invalid_message" }

    it "invalidates the input" do
      subject.address = "21 Rue Bergère"
      expect(subject).not_to be_valid
    end

    it "alerts the consumer" do
      subject.address = "address"
      subject.valid?
      expect(subject.errors[:address]).to include(invalid_message)
    end
  end
end
