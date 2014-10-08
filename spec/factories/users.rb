FactoryGirl.define do
  factory :user do
    sequence(:first_name) { |n| "User#{n}" }
    last_name  "Test"
    email { "#{first_name}.#{last_name}@example.com".downcase }
    password 'abcd1234'
  end
end
