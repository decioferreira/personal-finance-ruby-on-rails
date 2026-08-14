class MonthlyIncome < ApplicationRecord
  belongs_to :user

  normalizes :month, with: ->(month) { month.beginning_of_month }

  validates :month, presence: true, uniqueness: { scope: :user_id }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
