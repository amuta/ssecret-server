FactoryBot.define do
  factory :secret_access do
    association :secret
    association :group, factory: :group
    encrypted_dek { "encrypted_dek_#{SecureRandom.hex(16)}" }
  end
end
