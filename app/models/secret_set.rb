class SecretSet < ApplicationRecord
  # Relations
  belongs_to :created_by,
             class_name: "User",
             foreign_key: "created_by_user_id"
  has_many :secrets, dependent: :destroy
  has_many :secret_set_accesses, dependent: :destroy
  has_many :users, through: :secret_set_accesses

  # Validations
  validates :name, presence: true
  validates :created_by, presence: true
  validates :dek_encrypted, presence: true
end
