FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "mrmcuser#{n}@example.com" }
    password 'password'
  end
end
