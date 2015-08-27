FactoryGirl.define do
  factory :warning_email do
    model 'User'
    minutes 5
    recipient 'Test <test@test.com>'
  end
end
