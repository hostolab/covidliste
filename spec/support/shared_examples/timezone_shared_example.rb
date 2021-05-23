# frozen_string_literal: true

require "rails_helper"

shared_examples "a resource with a settable timezone" do
  subject { model }

  let(:model) { create(described_class.to_s.underscore.to_sym) }

  before do
    subject.department = department
    subject.validate
  end

  describe "assigning a timezone depending on the department" do
    {
      "Guyane" => "Georgetown",
      "Guadeloupe" => "America/Guadeloupe",
      "La Réunion" => "Indian/Reunion",
      "Martinique" => "America/Martinique",
      "Mayotte" => "Indian/Mayotte"
    }.each do |department_name, timezone|
      context "when the department is #{department_name}" do
        let(:department) { department_name }

        it { expect(subject.timezone).to eq timezone }
      end
    end

    context "when it is anything else" do
      let(:department) { "Basse-Normandie" }

      it { expect(subject.timezone).to eq "Europe/Paris" }
    end
  end
end
