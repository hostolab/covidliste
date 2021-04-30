require "rails_helper"

RSpec.describe VaccinationCenter, type: :model do
  let(:vaccination_center) { build(:vaccination_center, :from_paris) }

  describe "validations" do
    context "when vaccination center has no lat neither lon" do
      context "on default context" do
        it "is valid" do
          vaccination_center.lat = nil
          vaccination_center.lon = nil
          expect(vaccination_center).to be_valid
        end
      end
      context "on validation_by_admin context" do
        it "is invalid" do
          vaccination_center.lat = nil
          vaccination_center.lon = nil
          expect(vaccination_center.invalid?(:validation_by_admin)).to be true
        end
      end
    end

    context "when the user has incomplete address without zipcode" do
      context "on persistent context" do
        it "is always valid" do
          persistent_vaccination_center = create(:vaccination_center)
          persistent_vaccination_center.address = "21 Rue Bergère"
          expect(persistent_vaccination_center).to be_valid
          persistent_vaccination_center.address = "21 Rue Bergère 75009 Paris"
          expect(persistent_vaccination_center).to be_valid
        end
      end
      context "on new context" do
        it "is valid" do
          vaccination_center.address = generate(:french_address)
          expect(vaccination_center).to be_valid
          vaccination_center.address = "21 Rue Bergère 75009 Paris"
          expect(vaccination_center).to be_valid
        end
        it "is invalid" do
          vaccination_center.address = "21 Rue Bergère Paris"
          expect(vaccination_center).not_to be_valid
          expect(vaccination_center.errors[:address]).to include(I18n.t("errors.messages.missing_zipcode"))
          vaccination_center.address = "21 Rue Bergère Paris France"
          expect(vaccination_center).not_to be_valid
          expect(vaccination_center.errors[:address]).to include(I18n.t("errors.messages.missing_zipcode"))
        end
      end
    end
  end
end
