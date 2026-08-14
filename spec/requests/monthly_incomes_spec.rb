require "rails_helper"

RSpec.describe "MonthlyIncomes", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: user.password }
  end

  describe "when not authenticated" do
    it "redirects to sign in" do
      get new_monthly_income_path

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "POST /monthly_incomes" do
    it "creates income for the current user for the given month" do
      sign_in(user)

      expect {
        post monthly_incomes_path, params: { monthly_income: { month: "2026-08-01", amount: "2500.00" } }
      }.to change(user.monthly_incomes, :count).by(1)

      expect(response).to redirect_to(root_path(month: "2026-08-01"))
    end

    it "does not allow a second income record for the same month" do
      sign_in(user)
      create(:monthly_income, user: user, month: Date.new(2026, 8, 1))

      expect {
        post monthly_incomes_path, params: { monthly_income: { month: "2026-08-01", amount: "1000.00" } }
      }.not_to change(MonthlyIncome, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a negative amount" do
      sign_in(user)

      expect {
        post monthly_incomes_path, params: { monthly_income: { month: "2026-08-01", amount: "-5" } }
      }.not_to change(MonthlyIncome, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /monthly_incomes/:id/edit" do
    it "returns 404 for another user's income" do
      sign_in(user)
      income = create(:monthly_income, user: other_user)

      get edit_monthly_income_path(income)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /monthly_incomes/:id" do
    it "updates your own income" do
      sign_in(user)
      income = create(:monthly_income, user: user, amount: "2000.00")

      patch monthly_income_path(income), params: { monthly_income: { amount: "2600.00" } }

      expect(income.reload.amount).to eq(BigDecimal("2600.00"))
      expect(response).to redirect_to(root_path(month: income.month))
    end

    it "returns 404 when updating another user's income" do
      sign_in(user)
      income = create(:monthly_income, user: other_user, amount: "2000.00")

      patch monthly_income_path(income), params: { monthly_income: { amount: "2600.00" } }

      expect(response).to have_http_status(:not_found)
      expect(income.reload.amount).to eq(BigDecimal("2000.00"))
    end
  end
end
