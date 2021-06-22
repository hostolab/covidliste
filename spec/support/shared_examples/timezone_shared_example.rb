# frozen_string_literal: true

require "rails_helper"

shared_examples "a resource with a settable timezone" do
  subject { model }

  let(:model) { create(described_class.to_s.underscore.to_sym) }

  before do
    subject.geo_context = geo_context
    subject.validate
  end

  describe "assigning a timezone depending on the department" do
    {
      "971, Guadeloupe" => "America/Guadeloupe",
      "972, Martinique" => "America/Martinique",
      "973, Guyane" => "Georgetown",
      "974, La Réunion" => "Indian/Reunion",
      "976, Mayotte" => "Indian/Mayotte"
    }.each do |geo_context_name, timezone|
      context "when the geo_context is #{geo_context_name}" do
        let(:geo_context) { geo_context_name }

        it { expect(subject.timezone).to eq timezone }
      end
    end

    context "when it is anything else" do
      let(:geo_context) { "35, Ille-et-Villaine, Bretagne" }

      it { expect(subject.timezone).to eq "Europe/Paris" }
    end
  end
end
