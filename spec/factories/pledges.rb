# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :pledge do
    association :donor
    association :team
    amount 3.25
  end
end
