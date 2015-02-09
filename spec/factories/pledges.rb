# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :pledge do
    association :donor
    association :team
    amount { rand(1..100) * 0.25 }
  end
end
