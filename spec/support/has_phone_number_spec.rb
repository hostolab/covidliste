# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "has phone number" do |param|
  let(:model) { create(described_class.to_s.underscore.to_sym) }

  describe "#human_friendly_phone_number" do
    subject { model.human_friendly_phone_number }

    it "formats the phone number for the view" do
      allow(model).to receive(:phone_number).and_return("+33612345678")
      expect(subject).to eq "06 12 34 56 78"
    end
  end
end
