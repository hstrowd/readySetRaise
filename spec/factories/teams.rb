FactoryGirl.define do
  factory :team do
    sequence(:name) { |n| "Test Team #{n}" }
    pledge_target 15.5
    association :event
  end
end
