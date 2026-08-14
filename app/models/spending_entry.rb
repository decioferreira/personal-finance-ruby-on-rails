class SpendingEntry < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :date, presence: true
  validates :description, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :category_belongs_to_user

  private
    def category_belongs_to_user
      return if category.nil? || user.nil?

      errors.add(:category, "must belong to the same user") unless category.user_id == user_id
    end
end
