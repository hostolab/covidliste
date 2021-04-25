require "rails_helper"

RSpec.describe VaccinationCenter, type: :model do
  let(:vaccination_center) { create(:vaccination_center, lat: 42, lon: 2) }
  describe "validations" do
    context "when vaccination center has no lat neither lon" do
      subject { build(:vaccination_center, lat: nil, lon: nil) }

      context "on default context" do
        it "is valid" do
          expect(subject.valid?).to be true
        end
      end
      context "on validation_by_admin context" do
        it "is invalid" do
          expect(subject.invalid?(:validation_by_admin)).to be true
        end
      end
    end
  end
end
