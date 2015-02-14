require 'rails_helper'

RSpec.describe Organization, :type => :model do
  describe "when saving" do
    it "can be valid" do
      org = build :org
      expect(org).to be_valid

      org.save!
      expect(org.id).to_not be_nil
    end

    it "is invalid without a name" do
      org = build :org, name: nil
      expect(org).to_not be_valid
      expect(org.errors.keys).to include :name
    end

    it "is invalid without a description" do
      org = build :org, description: nil
      expect(org).to_not be_valid
      expect(org.errors.keys).to include :description
    end

    it "is invalid without a homepage URL" do
      org = build :org, homepage_url: nil
      expect(org).to_not be_valid
      expect(org.errors.keys).to include :homepage_url
    end

    it "is invalid without a creator" do
      org = build :org, creator: nil
      expect(org).to_not be_valid
      expect(org.errors.keys).to include :creator
    end

    it "is invalid without a URL key" do
      org = build :org, url_key: nil
      expect(org).to_not be_valid
      expect(org.errors.keys).to include :url_key
    end

    it "is invalid with a URL key that is not URL safe" do
      org = build :org, url_key: 'foo@bar:'
      expect(org).to_not be_valid
      expect(org.errors.keys).to include :url_key
    end
  end


  describe "associations" do
    it "can have members" do
      org = create :org

      user1 = create :user
      user2 = create :user
      user3 = create :user

      user1.organizations << org
      user2.organizations << org
      user3.organizations << org

      expect(org.members.to_a.sort).to eq [org.creator, user1, user2, user3].sort
    end

    it "can have fundraisers" do
      org = create :org

      fundraiser1 = build :fundraiser
      fundraiser1.organization = org
      fundraiser1.save!

      fundraiser2 = build :fundraiser
      fundraiser2.organization = org
      fundraiser2.save!

      expect(org.fundraisers.to_a.sort).to eq [fundraiser1, fundraiser2].sort
    end
  end

  describe "fundraiser categorization" do
    it "has past, present, and future fundraisers" do
      @org = create :org

      # Past Fundraisers:

      @pastfundraiser1 = create(:fundraiser, {
                                  organization: @org,
                                  creator: @org.creator,
                                  pledge_start_time: (DateTime.now - 4.months),
                                  pledge_end_time: (DateTime.now - 3.months)
                                })
      @pastfundraiser2 = create(:fundraiser, {
                                  organization: @org,
                                  creator: @org.creator,
                                  pledge_start_time: (DateTime.now - 2.months),
                                  pledge_end_time: (DateTime.now - 40.days)
                                })
      @pastfundraiser3 = create(:fundraiser, {
                                  organization: @org,
                                  creator: @org.creator,
                                  pledge_start_time: (DateTime.now - 3.days),
                                  pledge_end_time: (DateTime.now - 20.minutes)
                                })

      # Present Fundraisers:

      @presentfundraiser1 = create(:fundraiser, {
                                     organization: @org,
                                     creator: @org.creator,
                                     pledge_start_time: (DateTime.now - 1.month),
                                     pledge_end_time: (DateTime.now + 10.minutes)
                                   })
      @presentfundraiser2 = create(:fundraiser, {
                                     organization: @org,
                                     creator: @org.creator,
                                     pledge_start_time: (DateTime.now - 12.hours),
                                     pledge_end_time: (DateTime.now + 2.days)
                                   })

      # Future Fundraisers:

      @futurefundraiser1 = create(:fundraiser, {
                                    organization: @org,
                                    creator: @org.creator,
                                    pledge_start_time: (DateTime.now + 7.minutes),
                                    pledge_end_time: (DateTime.now + 3.hours)
                                  })
      @futurefundraiser2 = create(:fundraiser, {
                                    organization: @org,
                                    creator: @org.creator,
                                    pledge_start_time: (DateTime.now + 4.days),
                                    pledge_end_time: (DateTime.now + 4.days + 1.minute)
                                  })
      @futurefundraiser3 = create(:fundraiser, {
                                    organization: @org,
                                    creator: @org.creator,
                                    pledge_start_time: (DateTime.now + 1.months),
                                    pledge_end_time: (DateTime.now + 2.months)
                                  })
      @futurefundraiser4 = create(:fundraiser, {
                                    organization: @org,
                                    creator: @org.creator,
                                    pledge_start_time: (DateTime.now + 5.hours),
                                    pledge_end_time: (DateTime.now + 5.months)
                                  })

      expect(@org.fundraisers.past.sort).to eq [ @pastfundraiser1,
                                                 @pastfundraiser2,
                                                 @pastfundraiser3 ].sort

      expect(@org.fundraisers.present.sort).to eq [ @presentfundraiser1,
                                                    @presentfundraiser2 ].sort

      expect(@org.fundraisers.future.sort).to eq [ @futurefundraiser1,
                                                   @futurefundraiser2,
                                                   @futurefundraiser3,
                                                   @futurefundraiser4 ].sort
    end
  end

end
