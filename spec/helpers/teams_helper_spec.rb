require 'rails_helper'

RSpec.describe TeamsHelper, :type => :helper do
  describe "is_org_member" do
    before :each do
      @team = create :team
    end

    describe "user is logged in" do
      before :each do
        @current_user = create :user
        sign_in @current_user
      end

      describe "is not member of team's organization" do
        it "returns false" do
          expect(@team.organization.members.include?(@current_user)).to eq false
          expect(helper.is_org_member(@team)).to eq false
        end
      end

      describe "is member of team's organization" do
        before :each do
          @org = create :org, creator: @current_user
          @fundraiser = create :fundraiser, organization: @org
          @team = create :team, fundraiser: @fundraiser
        end

        it "returns true" do
          expect(@team.organization.members.include?(@current_user)).to eq true
          expect(helper.is_org_member(@team)).to eq true
        end
      end
    end

    describe "user not logged in" do
      it "returns false" do
        expect(helper.is_org_member(@team)).to eq false
      end
    end
  end
end
