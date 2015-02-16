require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the EventsHelper. For example:
#
# describe EventsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe EventsHelper, :type => :helper do
  describe "pledge_progress_percent" do
    before :each do
      @event = create :event
    end

    describe "when pledge_target is 0" do
      before :each do
        expect(@event.teams.count).to be 0
      end

      it "should be 0" do
        expect(helper.pledge_progress_percent(@event)).to eq 0
      end
    end

    describe "when pledge_target is not 0" do
      before :each do
        expect(@event.teams.count).to be 0
        @team = create :team, event: @event, pledge_target: 10
      end

      it "should be the pledge total as a percent of the target" do
        pledge_target = @team.pledge_target
        expected_percent = (@event.pledge_total / pledge_target) * 100
        expect(helper.pledge_progress_percent(@event)).to eq expected_percent.round
      end
    end
  end
end
