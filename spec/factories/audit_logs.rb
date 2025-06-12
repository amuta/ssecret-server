FactoryBot.define do
  factory :audit_log do
    user { nil }
    auditable { nil }
    action { 1 }
    status { 1 }
    details { "" }
  end
end
