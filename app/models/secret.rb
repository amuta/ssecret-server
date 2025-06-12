class Secret < ApplicationRecord
  has_many :secret_accesses, dependent: :destroy
  has_many :users, through: :secret_accesses
  has_many :items, dependent: :destroy
  accepts_nested_attributes_for :items, allow_destroy: true

  validates :name, presence: true

  def permissions_for(user)
    return nil unless user
    secret_accesses.find { |access| access.user_id == user.id }&.permissions
  end

  def dek_for(user)
    return nil unless user
    secret_accesses.find { |access| access.user_id == user.id }&.dek_encrypted
  end
end
