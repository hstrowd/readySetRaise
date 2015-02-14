require 'rails_helper'

RSpec.describe Organization, :type => :model do
  describe "when saving" do
    it "can be valid" do
      user = build :user
      expect(user).to be_valid

      user.save!
      expect(user.id).to_not be_nil
    end

    it "is invalid without a first name" do
      user = build :user, first_name: nil
      expect(user).to_not be_valid
      expect(user.errors.keys).to include :first_name
    end

    it "is invalid without a last name" do
      user = build :user, first_name: nil
      expect(user).to_not be_valid
      expect(user.errors.keys).to include :first_name
    end

    it "is invalid without a email" do
      user = build :user, email: nil
      expect(user).to_not be_valid
      expect(user.errors.keys).to include :email
    end

    it "is invalid without a password" do
      user = build :user, password: nil
      expect(user).to_not be_valid
      expect(user.errors.keys).to include :password
    end

    it "is valid without a phone number" do
      user = build :user, phone_number: nil
      expect(user).to be_valid
    end

    it "prevents cleartext retrieval of passwords" do
      clearPassword = 'secret'
      user = build :user, password: clearPassword

      expect(user.encrypted_password).to_not eq clearPassword
      expect(user.has_attribute?(:password)).to eq false
    end
  end


  describe "associations" do
    it "can have organizations" do
      user = create :user

      org1 = create :org
      org2 = create :org
      org3 = create :org
      org4 = create :org

      org1.members << user
      org2.members << user
      org3.members << user
      org4.members << user

      expect(user.organizations.sort).to eq [org1, org2, org3, org4].sort
    end
  end


  describe "helper methods" do
    it "creates a full name from the first and last" do
      user = create :user
      expect(user.full_name).to eq(user.first_name + ' ' + user.last_name)
    end
  end
end
