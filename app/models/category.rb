class Category < ApplicationRecord
  belongs_to :user
  has_many :spending_entries, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
end
