# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :team_descriptor do
    sequence(:singular) { |n| "Type #{n} Team" }
    plural { "#{singular}s" }
  end
end
