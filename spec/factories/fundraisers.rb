FactoryGirl.define do
  factory :fundraiser do
    title "Test Fundraiser"
    description "Test fundraiser's description."
    pledge_start_time { DateTime.now - 3.days }
    pledge_end_time { DateTime.now + 3.days }
    association :organization
    association :creator

    # Ensure the creator is a member of the associated org.
    after :create do |fundraiser, evaluator|
      fundraiser.organization.members << fundraiser.creator
    end
  end
end
