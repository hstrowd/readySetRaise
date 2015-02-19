FactoryGirl.define do
  factory :org, class: Organization, aliases: [:organization] do
    sequence(:name) { |n| "Org#{n}" }
    description "Test Organization"
    association :creator
    url_key { "#{name}".downcase }
    homepage_url { "http://#{name}.com" }
    donation_url { "http://#{name}.com/donate" }

    # Make the creator a member as well.
    after :create do |org, evaluator|
      org.members << org.creator
    end
  end
end
