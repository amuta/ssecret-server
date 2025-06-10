FactoryBot.define do
  factory :secret_set do
    sequence(:name) { |n| "Item Set #{n}" }
  end
end
