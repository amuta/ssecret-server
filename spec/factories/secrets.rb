FactoryBot.define do
  factory :secret do
    sequence(:key) { |n| "TEST_KEY_#{n}" }
    content { "encrypted_content_#{SecureRandom.hex(16)}" }
    association :secret_set
  end
end
