FactoryBot.define do
  factory :user do
    username { Faker::Internet.username(specifier: 5..20, separators: %w[_ -]) }
    password { 'password123' }
  end
end
