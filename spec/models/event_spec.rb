require 'rails_helper'

RSpec.describe Event, :type => :model do
  describe "when saving" do
    it "can be valid" do
      event = build :event
      expect(event).to be_valid

      event.save!
      expect(event.id).to_not be_nil
    end

    it "is invalid without a title" do
      event = build :event, title: nil
      expect(event).to_not be_valid
      expect(event.errors.keys).to include :title
    end

    it "is invalid without a fundraiser" do
      event = build :event, fundraiser: nil
      expect(event).to_not be_valid
      expect(event.errors.keys).to include :fundraiser
    end

    it "is invalid without a creator" do
      event = build :event, creator: nil
      expect(event).to_not be_valid
      expect(event.errors.keys).to include :creator
    end

    it "is invalid without a start time" do
      event = build :event, start_time: nil
      expect(event).to_not be_valid
      expect(event.errors.keys).to include :start_time
    end

    it "is invalid without a end time" do
      event = build :event, end_time: nil
      expect(event).to_not be_valid
      expect(event.errors.keys).to include :end_time
    end

    it "is invalid when start time is after end time" do
      event = build :event, start_time: DateTime.now, end_time: (DateTime.now - 3.hours)
      expect(event).to_not be_valid
      expect(event.errors.keys).to include :start_time
    end

    it "is invalid when start time is before fundraiser start time" do
      fundraiser = create :fundraiser, {
        pledge_start_time: (DateTime.now - 1.day),
        pledge_end_time: (DateTime.now + 2.days)
      }
      event = build :event, {
        fundraiser: fundraiser,
        start_time: (DateTime.now - 2.days),
        end_time: (DateTime.now + 3.hours)
      }
      expect(event).to_not be_valid
      expect(event.errors.keys).to include :start_time
    end

    it "is invalid when end time is after fundraiser end time" do
      fundraiser = create :fundraiser, {
        pledge_start_time: (DateTime.now - 1.day),
        pledge_end_time: (DateTime.now + 2.days)
      }
      event = build :event, {
        fundraiser: fundraiser,
        start_time: DateTime.now,
        end_time: (DateTime.now + 3.days)
      }
      expect(event).to_not be_valid
      expect(event.errors.keys).to include :end_time
    end

    it "is valid even without a description" do
      event = build :event, description: nil
      expect(event).to be_valid
    end
  end

  describe "associations" do
    it "can have teams" do
      event = create :event

      team1 = build :team
      team1.event = event
      team1.save!

      team2 = build :team
      team2.event = event
      team2.save!

      team3 = build :team
      team3.event = event
      team3.save!

      expect(event.teams.sort).to eq [team1, team2, team3].sort
    end

    it "has an organization through it's fundraiser" do
      event = create :event
      expect(event.organization).to eq event.fundraiser.organization
    end
  end

  describe "helper methods" do
    describe "when the start time is in the past" do
      describe "when the end time is in the past" do
        it "has started and ended" do
          event = create :event, {
            start_time: (DateTime.now - 3.hours),
            end_time: (DateTime.now - 2.hours)
          }

          expect(event).to be_valid
          expect(event.has_started?).to eq true
          expect(event.has_ended?).to eq true
          expect(event.is_active?).to eq false
        end
      end

      describe "when the end time is in the future" do
        it "has started and not ended" do
          event = create :event, {
            start_time: (DateTime.now - 3.hours),
            end_time: (DateTime.now + 2.hours)
          }

          expect(event).to be_valid
          expect(event.has_started?).to eq true
          expect(event.has_ended?).to eq false
          expect(event.is_active?).to eq true
        end
      end
    end

    describe "when the start time is in the future" do
      describe "when the end time is in the past" do
        it "is not valid" do
          event = build :event, {
            start_time: (DateTime.now + 3.hours),
            end_time: (DateTime.now - 2.hours)
          }

          expect(event).to_not be_valid
        end
      end

      describe "when the end time is in the future" do
        it "has not started and not ended" do
          event = create :event, {
            start_time: (DateTime.now + 1.hour),
            end_time: (DateTime.now + 2.days)
          }

          expect(event).to be_valid
          expect(event.has_started?).to eq false
          expect(event.has_ended?).to eq false
          expect(event.is_active?).to eq false
        end
      end
    end

    it "calculates the pledge target based on all teams from all events" do
      event = create :event

      team1 = create :team, event: event, pledge_target: 50
      team2 = create :team, event: event, pledge_target: 375.2
      team3 = create :team, event: event, pledge_target: 100

      expect(event.pledge_target).to eq 525.2
    end

    it "calculates the pledge total based on all teams from all events" do
      event = create :event

      team1 = create :team, event: event
      create :pledge, team: team1, amount: 10
      create :pledge, team: team1, amount: 7
      create :pledge, team: team1, amount: 10.5
      create :pledge, team: team1, amount: 27.3
      create :pledge, team: team1, amount: 17
      create :pledge, team: team1, amount: 43
      create :pledge, team: team1, amount: 5.2

      team2 = create :team, event: event
      create :pledge, team: team2, amount: 107
      create :pledge, team: team2, amount: 8.1
      create :pledge, team: team2, amount: 0.6

      team3 = create :team, event: event
      create :pledge, team: team3, amount: 52
      create :pledge, team: team3, amount: 11
      create :pledge, team: team3, amount: 33.8
      create :pledge, team: team3, amount: 4

      expect(event.pledge_total).to eq 336.5
    end
  end
end
