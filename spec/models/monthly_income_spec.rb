require "rails_helper"

RSpec.describe MonthlyIncome, type: :model do
  it "has a valid factory" do
    expect(build(:monthly_income)).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject { create(:monthly_income) }

    it { is_expected.to validate_presence_of(:month) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_uniqueness_of(:month).scoped_to(:user_id) }
  end

  it "allows a zero amount, meaning no income that month" do
    income = build(:monthly_income, amount: 0)

    expect(income).to be_valid
  end

  it "rejects a negative amount" do
    income = build(:monthly_income, amount: -1)

    expect(income).not_to be_valid
  end

  describe "month normalization" do
    it "normalizes any date in the month to the first day of that month" do
      income = create(:monthly_income, month: Date.new(2026, 8, 17))

      expect(income.month).to eq(Date.new(2026, 8, 1))
    end
  end

  it "allows different users to have income for the same month" do
    income_a = create(:monthly_income, month: Date.new(2026, 8, 1))
    income_b = build(:monthly_income, month: Date.new(2026, 8, 1))

    expect(income_b).to be_valid
    expect(income_a.user_id).not_to eq(income_b.user_id)
  end
end
