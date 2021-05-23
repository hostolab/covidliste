# frozen_string_literal: true

require "rails_helper"

shared_examples "a resource with a settable timezone" do |param|
  subject { model }

  let(:model) { create(described_class.to_s.underscore.to_sym) }

  before do
    subject.department = department
    subject.validate
  end

  describe "assiging a timezone depending on the department" do
    context "when the department is French Guyane" do
      let(:department) { "Guyane" }

      it { expect(subject.timezone).to eq "Georgetown" }
    end

    context "when the department is Guadeloupe" do
      let(:department) { "Guadeloupe" }

      it { expect(subject.timezone).to eq "America/Guadeloupe" }
    end

    context "when the department is La Réunion" do
      let(:department) { "La Réunion" }

      it { expect(subject.timezone).to eq "Indian/Reunion" }
    end

    context "when the department is Martinique" do
      let(:department) { "Martinique" }

      it { expect(subject.timezone).to eq "America/Martinique" }
    end

    context "when the department is Mayotte" do
      let(:department) { "Mayotte" }

      it { expect(subject.timezone).to eq "Indian/Mayotte" }
    end

    context "when it is anything else" do
      let(:department) { "Basse-Normandie" }

      it { expect(subject.timezone).to eq "Europe/Paris" }
    end
  end
end
