FactoryGirl.define do
  factory :team do
    name "Test Team"
    pledge_target 15
    association :event
  end
end
