require 'rails_helper'

RSpec.describe Team, :type => :model do
  describe "when saving" do
    it "can be valid" do
      team = build :team
      expect(team).to be_valid

      team.save!
      expect(team.id).to_not be_nil
    end

    it "is invalid without a name" do
      team = build :team, name: nil
      expect(team).to_not be_valid
      expect(team.errors.keys).to include :name
    end

    it "is invalid without an event" do
      team = build :team, event: nil
      expect(team).to_not be_valid
      expect(team.errors.keys).to include :event
    end

    it "is invalid if the pledge target is not a number" do
      team = build :team, pledge_target: '$100'
      expect(team).to_not be_valid
      expect(team.errors.keys).to include :pledge_target
    end

    it "is valid even without an pledge target" do
      team = build :team, pledge_target: nil
      expect(team).to be_valid
    end
  end

  describe "associations" do
    it "can have pledges" do
      team = create :team

      pledge1 = build :pledge
      pledge1.team = team
      pledge1.save!

      pledge2 = build :pledge
      pledge2.team = team
      pledge2.save!

      pledge3 = build :pledge
      pledge3.team = team
      pledge3.save!

      pledge4 = build :pledge
      pledge4.team = team
      pledge4.save!

      pledge5 = build :pledge
      pledge5.team = team
      pledge5.save!

      expect(team.pledges.to_a.sort).to eq [pledge1, pledge2, pledge3, pledge4, pledge5].sort
    end
  end

  describe "helper methods" do
    it "calculates the pledge total over all pledges" do
      team = create :team

      create :pledge, team: team, amount: 10
      create :pledge, team: team, amount: 7
      create :pledge, team: team, amount: 10.5
      create :pledge, team: team, amount: 27.3
      create :pledge, team: team, amount: 17
      create :pledge, team: team, amount: 43
      create :pledge, team: team, amount: 5.2

      expect(team.pledge_total).to eq 120.0
    end
  end
end
