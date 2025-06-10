FactoryBot.define do
  factory :secret_set do
    sequence(:name) { |n| "Secret Set #{n}" }
    association :created_by, factory: :user
  end
end
