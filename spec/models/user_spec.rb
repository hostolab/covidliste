require "rails_helper"

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe "Fields validation" do
    it "has a valid factory" do
      expect(user).to be_valid
    end

    it "is invalid without a first_name" do
      user.firstname = nil
      expect(user).to be_valid
    end

    it "is invalid without a last_name" do
      user.lastname = nil
      expect(user).to be_valid
    end

    it "is invalid without lat or lon" do
      user.lat = nil
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

  describe "latitude/lontidude" do
    it "randomize lat/lon at user creation" do
      lat = 48.345
      lon = 2.123
      user = create(:user, lat: lat, lon: lon)
      expect(user.lat).to_not eq(lat)
      expect(user.lon).to_not eq(lon)
    end

    it "randomize lat/lon at user update" do
      lat = 48.345
      lon = 2.123
      user = create(:user)
      user.reload
      user.update(lat: lat, lon: lon)
      expect(user.lat).to_not eq(lat)
      expect(user.lon).to_not eq(lon)
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

  describe "Email domain" do
    it "It extracts email domain" do
      user = create(:user, email: "test+1@thisisfakesauvonslesvaccins.com")
      expect(user.email_domain).to eq("thisisfakesauvonslesvaccins.com")
    end
  end

  describe "Phone format" do
    it_behaves_like "has phone number"

    it "format phone number correctly" do
      user.phone_number = "06 11 22 33 44"
      expect(user).to be_valid
      expect(user.phone_number).to eq("+33611223344")

      user.phone_number = "06.11.22.33.44"
      expect(user).to be_valid
      expect(user.phone_number).to eq("+33611223344")

      user.phone_number = "33 6.11.22.33.44"
      expect(user).to be_valid
      expect(user.phone_number).to eq("+33611223344")
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

  describe "to_s" do
    it "should return email" do
      user = User.new(email: "test@coviliste.com")
      expect(user.to_s).to eq("test@coviliste.com")
    end

    it "should return firstname + lastname" do
      user = User.new(firstname: "George", lastname: "Abitbol")
      expect(user.to_s).to eq("George Abitbol")
    end

    it "should return Anonymous" do
      user = create(:user)
      user.anonymize!
      expect(user.to_s).to eq("Anonymous")
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

  describe "Age" do
    it "should be increased on my birthday" do
      today = Time.now.utc.to_date
      user.birthdate = today - 20.years
      expect(user.age).to eq(20)
    end

    it "should be correct before my birthday" do
      today = Time.now.utc.to_date
      user.birthdate = today - 20.years + 1.day
      expect(user.age).to eq(19)
    end

    it "should be correct after my birthday" do
      today = Time.now.utc.to_date
      user.birthdate = today - 20.years - 1.day
      expect(user.age).to eq(20)
    end
  end

  describe "Roles" do
    context "super admin" do
      before { user.add_role(:super_admin) }
      it "should have all roles" do
        expect(user.has_role?(:admin)).to eq(true)
        expect(user.has_role?(:dev_admin)).to eq(true)
        expect(user.has_role?(:supply_admin)).to eq(true)
        expect(user.has_role?(:supply_member)).to eq(true)
        expect(user.has_role?(:support_admin)).to eq(true)
        expect(user.has_role?(:support_member)).to eq(true)
        expect(user.has_role?(:volunteer)).to eq(true)
      end
    end

    context "support member" do
      before { user.add_role(:support_member) }
      it "should not have admin roles" do
        expect(user.has_role?(:admin)).to eq(false)
        expect(user.has_role?(:super_admin)).to eq(false)
        expect(user.has_role?(:supply_admin)).to eq(false)
        expect(user.has_role?(:support_admin)).to eq(false)
      end
    end
  end
end
