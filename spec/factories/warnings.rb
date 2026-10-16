FactoryBot.define do
  factory :warning, class: 'ActsAsWarnable::Warning' do
    source { 'FactoryBot' }
    message { 'This is a just drill' }
  end
end
