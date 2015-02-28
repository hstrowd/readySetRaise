# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    title "Test Event"
    description "Test event's description."
    sequence(:url_key) { |n|  "event#{n}" }
    association :fundraiser
    association :creator
    start_time { DateTime.now - 1.day }
    end_time { DateTime.now + 1.day }
    team_descriptor { TeamDescriptor.find(1) }

    # Ensure the creator is a member of the associated org.
    after :create do |event, evaluator|
      event.fundraiser.organization.members << event.creator
    end
  end
end
