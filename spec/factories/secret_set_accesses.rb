FactoryBot.define do
  factory :secret_set_access do
    association :user
    association :secret
    dek_encrypted { "encrypted_dek_#{SecureRandom.hex(16)}" }
  end
end
