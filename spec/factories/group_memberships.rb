FactoryBot.define do
  factory :group_membership do
    association :user
    association :group
    encrypted_group_key { "encrypted_group_key_#{SecureRandom.hex(16)}" }
    role { :member }

    trait :admin do
      role { :admin }
    end
  end
end
