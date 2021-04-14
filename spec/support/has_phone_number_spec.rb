# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "has phone number" do |param|
  subject { model }

  let(:model) { create(described_class.to_s.underscore.to_sym) }
  let(:phone_number) { "+33612345678" }

  before do
    subject.phone_number = phone_number
  end

  describe "validating the phone number" do
    context "when the phone number is not possible" do
      let(:phone_number) { "1234567" }

      it { is_expected.not_to be_valid }
    end

    context "when the phone number is not a mobile phone" do
      let(:phone_number) { Faker::PhoneNumber.phone_number }

      it { is_expected.not_to be_valid }
    end

    context "when the phone number is a French mobile phone" do
      let(:phone_number) { "06 12 34 56 78" }

      it { is_expected.to be_valid }
    end

    context "when the phone number is a non-attributed French mobile phone" do
      let(:phone_number) { "07 12 34 56 78" }

      it { is_expected.not_to be_valid }
    end

    context "when the phone number is a valid foreign mobile phone" do
      let(:phone_number) { "+49-162-5555-223" }

      it { is_expected.to be_valid }
    end
  end

  describe "#human_friendly_phone_number" do
    it "returns the national format of the phone number for the view" do
      expect(subject.human_friendly_phone_number).to eq "06 12 34 56 78"
    end

    context "when the phone number is not French" do
      let(:phone_number) { "+49-162-5555-223" }

      it "returns the e164 (international) format of the phone number for the view" do
        expect(subject.human_friendly_phone_number).to eq "+491625555223"
      end
    end
  end
end
