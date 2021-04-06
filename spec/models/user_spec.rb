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
      user.phone_number = '06 11 22 33 44'
      expect(user).to be_valid
      expect(user.phone_number).to eq('33611223344')

      user.phone_number = '06.11.22.33.44'
      expect(user).to be_valid
      expect(user.phone_number).to eq('33611223344')

      user.phone_number = '33 6.11.22.33.44'
      expect(user).to be_valid
      expect(user.phone_number).to eq('33611223344')
    end
  end
end
