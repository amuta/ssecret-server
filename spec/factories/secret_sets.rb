FactoryBot.define do
  factory :secret_set do
    sequence(:name) { |n| "Secret Set #{n}" }
  end
end
