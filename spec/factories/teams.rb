# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :team do
    name "MyString"
    pledge_target 1.5
  end
end
