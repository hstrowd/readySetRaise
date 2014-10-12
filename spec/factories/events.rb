# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    title "MyString"
    description "MyText"
    start_time "2014-10-12 13:11:45"
    end_time "2014-10-12 13:11:45"
  end
end
