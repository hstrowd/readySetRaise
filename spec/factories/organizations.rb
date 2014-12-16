FactoryGirl.define do
  factory :org, class: Organization do
    sequence(:name) { |n| "Org#{n}" }
    description "Test Organization"
    association :creator, factory: :user
    url_key { "#{name}".downcase }
    homepage_url { "http://#{name}.com" }
  end
end
