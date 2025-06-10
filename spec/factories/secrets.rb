FactoryBot.define do
  factory :secret do
    sequence(:name) { |n| "Item Set #{n}" }
  end
end
