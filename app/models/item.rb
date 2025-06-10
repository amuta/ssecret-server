class Item < ApplicationRecord
  belongs_to :secret

  validates :key, format: { with: /\A[A-Z0-9_]+\z/, message: "must be in uppercase with words separated by underscores" }
  validates :content, presence: true
end
