class MonthlyIncomesController < ApplicationController
  before_action :set_monthly_income, only: %i[ edit update ]

  def new
    @monthly_income = Current.user.monthly_incomes.new(month: parse_month(params[:month]))
  end

  def edit
  end

  def create
    @monthly_income = Current.user.monthly_incomes.new(monthly_income_params)

    if @monthly_income.save
      redirect_to root_path(month: @monthly_income.month), notice: "Income was successfully saved."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @monthly_income.update(monthly_income_params)
      redirect_to root_path(month: @monthly_income.month), notice: "Income was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def set_monthly_income
      @monthly_income = Current.user.monthly_incomes.find(params.expect(:id))
    end

    def monthly_income_params
      params.expect(monthly_income: [ :month, :amount ])
    end
end
