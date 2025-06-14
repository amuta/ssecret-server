class User < ApplicationRecord
  include JwtAuthenticatable
  include PrivateKeyAuthenticable

  has_secure_password validations: false

  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships

  validates :username, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_-]+\z/, message: "can only contain letters, numbers, underscore, and hyphen" }
  validates :raw_public_key, public_key: true, allow_blank: true

  has_many :secret_accesses, through: :groups
  has_many :secrets, through: :secret_accesses

  attr_accessor :raw_public_key

  def personal_group
    # Find the group that is personal and that this user is the only member of.
    groups.find_by(is_personal: true)
  end
end
