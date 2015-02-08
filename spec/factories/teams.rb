FactoryGirl.define do
  factory :team do
    name "Test Team"
    pledge_target 15.5
    association :event
  end
end
