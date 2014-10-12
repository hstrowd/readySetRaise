# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :pledge do
    donor ""
    team ""
    amount 1.5
  end
end
