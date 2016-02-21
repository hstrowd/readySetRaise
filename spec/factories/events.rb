# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    title "Test Event"
    description "Test event's description."
    sequence(:url_key) { |n|  "event#{n}" }
    association :creator
    start_time { DateTime.now - 1.day }
    end_time { DateTime.now + 1.day }
    team_descriptor { TeamDescriptor.find(1) }
    donation_url { "http://#{name}.com/donate" }
  end
end
