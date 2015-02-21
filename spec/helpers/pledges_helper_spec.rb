require 'rails_helper'

RSpec.describe PledgesHelper, :type => :helper do
  describe "donor_name" do
    before :each do
      @donor = create :user, first_name: 'James', last_name: 'Smith'
      @pledge = create :pledge, donor: @donor
    end

    describe "when pledge is anonymous" do
      before :each do
        @pledge.anonymous = true
      end

      it "should be 'Anonymous'" do
        expect(helper.donor_name(@pledge)).to eq "Anonymous"
      end
    end

    describe "when pledge is not anonymous" do
      before :each do
        @pledge.anonymous = false
      end

      it "should be 'Anonymous'" do
        expect(helper.donor_name(@pledge)).to eq "James Smith"
      end
    end
  end
end
