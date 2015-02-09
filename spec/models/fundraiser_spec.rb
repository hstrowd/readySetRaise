require 'rails_helper'

RSpec.describe Fundraiser, :type => :model do
  describe "when saving" do
    it "can be valid" do
      fundraiser = build :fundraiser
      expect(fundraiser).to be_valid

      fundraiser.save!
      expect(fundraiser.id).to_not be_nil
    end

    it "is invalid without a title" do
      fundraiser = build :fundraiser, title: nil
      expect(fundraiser).to_not be_valid
    end

    it "is invalid without a pledge start time" do
      fundraiser = build :fundraiser, pledge_start_time: nil
      expect(fundraiser).to_not be_valid
    end

    it "is invalid without a pledge end time" do
      fundraiser = build :fundraiser, pledge_end_time: nil
      expect(fundraiser).to_not be_valid
    end

    it "is invalid without an organization" do
      fundraiser = build :fundraiser, organization: nil
      expect(fundraiser).to_not be_valid
    end

    it "is invalid without a creator" do
      fundraiser = build :fundraiser, creator: nil
      expect(fundraiser).to_not be_valid
    end

    it "is invalid if the pledge start time is after the end time" do
      fundraiser = build :fundraiser, {
        pledge_start_time: DateTime.now,
        pledge_end_time: (DateTime.now - 3.minutes)
      }
      expect(fundraiser).to_not be_valid
    end

    it "is valid even without a description" do
      fundraiser = build :fundraiser, description: nil
      expect(fundraiser).to be_valid
    end
  end

  describe "associations" do
    it "can have events" do
      fundraiser = create :fundraiser

      event1 = build :event
      event1.fundraiser = fundraiser
      event1.save!

      event2 = build :event
      event2.fundraiser = fundraiser
      event2.save!

      expect(fundraiser.events.sort).to eq [event1, event2].sort
    end
  end

  describe "helper methods" do
    describe "when the pledge start time is in the past" do
      describe "when the pledge end time is in the past" do
        it "has started and ended" do
          fundraiser = create :fundraiser, {
            pledge_start_time: (DateTime.now - 3.hours),
            pledge_end_time: (DateTime.now - 2.hours)
          }

          expect(fundraiser).to be_valid
          expect(fundraiser.has_started?).to eq true
          expect(fundraiser.has_ended?).to eq true
          expect(fundraiser.is_active?).to eq false
        end
      end

      describe "when the pledge end time is in the future" do
        it "has started and not ended" do
          fundraiser = create :fundraiser, {
            pledge_start_time: (DateTime.now - 3.hours),
            pledge_end_time: (DateTime.now + 2.hours)
          }

          expect(fundraiser).to be_valid
          expect(fundraiser.has_started?).to eq true
          expect(fundraiser.has_ended?).to eq false
          expect(fundraiser.is_active?).to eq true
        end
      end
    end

    describe "when the pledge start time is in the future" do
      describe "when the pledge end time is in the past" do
        it "is not valid" do
          fundraiser = build :fundraiser, {
            pledge_start_time: (DateTime.now + 3.hours),
            pledge_end_time: (DateTime.now - 2.hours)
          }

          expect(fundraiser).to_not be_valid
        end
      end

      describe "when the pledge end time is in the future" do
        it "has not started and not ended" do
          fundraiser = create :fundraiser, {
            pledge_start_time: (DateTime.now + 1.hour),
            pledge_end_time: (DateTime.now + 2.days)
          }

          expect(fundraiser).to be_valid
          expect(fundraiser.has_started?).to eq false
          expect(fundraiser.has_ended?).to eq false
          expect(fundraiser.is_active?).to eq false
        end
      end
    end

    it "calculates the pledge target based on all teams from all events" do
      fundraiser = create :fundraiser

      event1 = create :event, fundraiser: fundraiser
      team11 = create :team, event: event1, pledge_target: 50
      team12 = create :team, event: event1, pledge_target: 375.2
      team13 = create :team, event: event1, pledge_target: 100

      event2 = create :event, fundraiser: fundraiser
      team21 = create :team, event: event2, pledge_target: 210.7
      team22 = create :team, event: event2, pledge_target: 75.9

      expect(fundraiser.pledge_target).to eq 811.8
    end

    it "calculates the pledge total based on all teams from all events" do
      fundraiser = create :fundraiser

      event1 = create :event, fundraiser: fundraiser

      team11 = create :team, event: event1
      create :pledge, team: team11, amount: 10
      create :pledge, team: team11, amount: 7
      create :pledge, team: team11, amount: 10.5
      create :pledge, team: team11, amount: 27.3
      create :pledge, team: team11, amount: 17
      create :pledge, team: team11, amount: 43
      create :pledge, team: team11, amount: 5.2

      team12 = create :team, event: event1
      create :pledge, team: team12, amount: 107
      create :pledge, team: team12, amount: 8.1
      create :pledge, team: team12, amount: 0.6

      team13 = create :team, event: event1
      create :pledge, team: team13, amount: 52
      create :pledge, team: team13, amount: 11
      create :pledge, team: team13, amount: 33.8
      create :pledge, team: team13, amount: 4

      event2 = create :event, fundraiser: fundraiser

      team21 = create :team, event: event2
      create :pledge, team: team21, amount: 73
      create :pledge, team: team21, amount: 30.4

      team22 = create :team, event: event2
      create :pledge, team: team22, amount: 1.7
      create :pledge, team: team22, amount: 53
      create :pledge, team: team22, amount: 204
      create :pledge, team: team22, amount: 7.3

      expect(fundraiser.pledge_total).to eq 705.9
    end
  end
end
