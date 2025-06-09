FactoryBot.define do
  factory :secret_set do
    sequence(:name) { |n| "Secret Set #{n}" }
    association :created_by, factory: :user
    dek_encrypted { "encrypted_dek_#{SecureRandom.hex(16)}" }
  end
end
