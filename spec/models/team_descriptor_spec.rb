require 'rails_helper'

RSpec.describe TeamDescriptor, :type => :model do
  include TestHelpers

  describe "validations" do
    it "can be valid" do
      team_descriptor = build :team_descriptor
      expect(team_descriptor).to be_valid

      team_descriptor.save!
      expect(team_descriptor.id).to_not be_nil
    end

    it "is invalid without a singular form" do
      team_descriptor = build :team_descriptor, singular: nil
      expect(team_descriptor).to_not be_valid
      expect(team_descriptor.errors.keys).to include :singular
    end

    it "is invalid when the singular form is too long" do
      team_descriptor = build :team_descriptor, singular: generate_random_string(256)
      expect(team_descriptor).to_not be_valid
      expect(team_descriptor.errors.keys).to include :singular
    end

    it "is invalid without a plural form" do
      team_descriptor = build :team_descriptor, plural: nil
      expect(team_descriptor).to_not be_valid
      expect(team_descriptor.errors.keys).to include :plural
    end

    it "is invalid when the singular form is too long" do
      team_descriptor = build :team_descriptor, plural: generate_random_string(256)
      expect(team_descriptor).to_not be_valid
      expect(team_descriptor.errors.keys).to include :plural
    end
  end
end
