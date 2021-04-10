require "rails_helper"

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe "Fields validation" do
    it "has a valid factory" do
      expect(user).to be_valid
    end

    it "is invalid without a first_name" do
      user.firstname = nil
      expect(user).to_not be_valid
    end

    it "is invalid without a last_name" do
      user.lastname = nil
      expect(user).to_not be_valid
    end

    it "is invalid without an address" do
      user.address = nil
      expect(user).to_not be_valid
    end

    it "is invalid without a birthdate" do
      user.birthdate = nil
      expect(user).to_not be_valid
    end

    it "is invalid without an email" do
      user.email = nil
      expect(user).to_not be_valid
    end
  end

  describe "Email format" do
    it "is invalid without a fake MX record" do
      user.email = "test@thisisfakesauvonslesvaccins.com"
      expect(user).to_not be_valid
    end

    it "is invalid without a registered wrong format" do
      user.email = "test@gamil.com"
      expect(user).to_not be_valid

      user.email = "test@hotmal.com"
      expect(user).to_not be_valid
    end
  end

  describe "Phone format" do
    it "format phone number correctly" do
      user.phone_number = "06 11 22 33 44"
      expect(user).to be_valid
      expect(user.phone_number).to eq("33611223344")

      user.phone_number = "06.11.22.33.44"
      expect(user).to be_valid
      expect(user.phone_number).to eq("33611223344")

      user.phone_number = "33 6.11.22.33.44"
      expect(user).to be_valid
      expect(user.phone_number).to eq("33611223344")
    end
  end

  describe "Full name" do
    it "should return firstname + lastname" do
      user = User.new(firstname: "George", lastname: "Abitbol")
      expect(user.full_name).to eq("George Abitbol")
    end

    it "should return Anonymous" do
      user = create(:user)
      user.anonymize!
      expect(user.full_name).to eq("Anonymous")
    end
  end

  describe "Anonymisation" do
    it "anonymise every fields" do
      user = create(:user)
      user.anonymize!
      expect(user.firstname).to be_nil
      expect(user.lastname).to be_nil
      expect(user.address).to be_nil
      expect(user.lat).to be_nil
      expect(user.lon).to be_nil
      expect(user.zipcode).to be_nil
      expect(user.city).to be_nil
      expect(user.geo_citycode).to be_nil
      expect(user.geo_context).to be_nil
      expect(user.phone_number).to be_nil
      expect(user.birthdate).to be_nil
      expect(user.anonymized_at).not_to be_nil
    end
  end
end
