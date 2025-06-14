FactoryBot.define do
  factory :user do
    username { Faker::Internet.username(specifier: 5..20, separators: %w[_ -]) }
    password { 'password123' }

    before(:create) do |user, evaluator|
      group = Group.personal.find_or_create_by!(
        name: "#{user.username}-personal",
      )
      membership = GroupMembership.new(
        user: user,
        group: group,
        role: :admin, # A user is always an admin of their own personal group.
        encrypted_group_key: "#{Faker::Crypto.sha256}", # Simulating an encrypted key
      )
      user.group_memberships << membership
    end
  end
end
