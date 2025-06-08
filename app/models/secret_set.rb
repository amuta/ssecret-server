class SecretSet < ApplicationRecord
  belongs_to :created_by, class_name: "User"
  has_many :secrets, dependent: :destroy
  has_many :secret_set_accesses, dependent: :destroy
  has_many :users, through: :secret_set_accesses

  # Alias the association for clarity, since 'users' is used for the sharing relationship
  alias_attribute :shared_users, :users

  validates :name, presence: true
  validates :created_by_user_id, presence: true
end
