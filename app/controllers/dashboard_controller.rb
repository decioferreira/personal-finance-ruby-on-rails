class DashboardController < ApplicationController
  def show
    @month = parse_month(params[:month])
    @income = Current.user.monthly_incomes.find_by(month: @month)
    spending_entries = Current.user.spending_entries.for_month(@month)

    @total_spent = spending_entries.sum(:amount)
    @remaining = (@income&.amount || 0) - @total_spent
    @category_totals = spending_entries.joins(:category)
      .group("categories.name")
      .sum(:amount)
      .sort_by { |_name, amount| -amount }
  end
end
