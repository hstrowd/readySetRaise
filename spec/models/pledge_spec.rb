require 'rails_helper'

RSpec.describe Pledge, :type => :model do
  describe "when saving" do
    it "can be valid" do
      pledge = build :pledge
      expect(pledge).to be_valid

      pledge.save!
      expect(pledge.id).to_not be_nil
    end

    it "is invalid without an amount" do
      pledge = build :pledge, amount: nil
      expect(pledge).to_not be_valid
    end

    it "is invalid if amount is not a number" do
      pledge = build :pledge, amount: "$10"
      expect(pledge).to_not be_valid
    end

    it "is invalid without a team" do
      pledge = build :pledge, team: nil
      expect(pledge).to_not be_valid
    end

    it "is invalid without an donor" do
      pledge = build :pledge, donor: nil
      expect(pledge).to_not be_valid
    end
  end

  describe "associations" do
    it "has an event through it's team" do
      pledge = create :pledge
      expect(pledge.event).to eq pledge.team.event
    end

    it "has an fundraiser through it's event" do
      pledge = create :pledge
      expect(pledge.fundraiser).to eq pledge.event.fundraiser
    end

    it "has an organization through it's fundraiser" do
      pledge = create :pledge
      expect(pledge.organization).to eq pledge.fundraiser.organization
    end
  end
end
