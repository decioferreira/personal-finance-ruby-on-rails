class SpendingEntriesController < ApplicationController
  before_action :set_spending_entry, only: %i[ edit update destroy ]

  def index
    @month = parse_month(params[:month])
    @spending_entries = Current.user.spending_entries.for_month(@month).order(date: :desc)
    @total = @spending_entries.sum(:amount)
  end

  def new
    @spending_entry = Current.user.spending_entries.new(date: Date.current)
  end

  def edit
  end

  def create
    @spending_entry = Current.user.spending_entries.new(spending_entry_params)

    if @spending_entry.save
      redirect_to spending_entries_path(month: @spending_entry.date.beginning_of_month), notice: "Spending entry was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @spending_entry.update(spending_entry_params)
      redirect_to spending_entries_path(month: @spending_entry.date.beginning_of_month), notice: "Spending entry was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @spending_entry.destroy!
    redirect_to spending_entries_path(month: @spending_entry.date.beginning_of_month), notice: "Spending entry was successfully destroyed.", status: :see_other
  end

  private
    def set_spending_entry
      @spending_entry = Current.user.spending_entries.find(params.expect(:id))
    end

    def spending_entry_params
      params.expect(spending_entry: [ :date, :amount, :description, :category_id ])
    end

    def parse_month(value)
      Date.parse(value).beginning_of_month
    rescue TypeError, ArgumentError
      Date.current.beginning_of_month
    end
end
