FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "Group #{n}" }

    trait :personal do
      is_personal { true }
    end
  end
end
