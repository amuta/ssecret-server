FactoryBot.define do
  factory :secret do
    key { "MyString" }
    content { "MyText" }
    secret_set { nil }
  end
end
