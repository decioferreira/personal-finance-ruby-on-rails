require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:user) { create(:user) }
  let(:food) { create(:category, user: user, name: "Food") }
  let(:transport) { create(:category, user: user, name: "Transport") }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: user.password }
  end

  describe "when not authenticated" do
    it "redirects to sign in" do
      get root_path

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "GET / (dashboard)" do
    it "defaults to the current month when no month param is given" do
      sign_in(user)

      get root_path

      expect(response).to have_http_status(:ok)
    end

    it "shows income, spending, and remaining for the selected month" do
      sign_in(user)
      create(:monthly_income, user: user, month: Date.new(2026, 8, 1), amount: "2500.00")
      create(:spending_entry, user: user, category: food, date: Date.new(2026, 8, 10), amount: "320.50")
      create(:spending_entry, user: user, category: transport, date: Date.new(2026, 8, 12), amount: "85.20")

      get root_path(month: "2026-08-01")

      expect(response.body).to include("€2,500.00")
      expect(response.body).to include("€405.70")
      expect(response.body).to include("€2,094.30")
    end

    it "excludes spending and income from adjacent months" do
      sign_in(user)
      create(:monthly_income, user: user, month: Date.new(2026, 7, 1), amount: "1000.00")
      create(:spending_entry, user: user, category: food, date: Date.new(2026, 7, 31), amount: "50.00")
      create(:spending_entry, user: user, category: food, date: Date.new(2026, 9, 1), amount: "60.00")

      get root_path(month: "2026-08-01")

      expect(response.body).to include("€0.00")
      expect(response.body).not_to include("€1,000.00")
    end

    it "includes spending on the first and last day of the month" do
      sign_in(user)
      create(:spending_entry, user: user, category: food, date: Date.new(2026, 8, 1), amount: "10.00")
      create(:spending_entry, user: user, category: food, date: Date.new(2026, 8, 31), amount: "20.00")

      get root_path(month: "2026-08-01")

      expect(response.body).to include("€30.00")
    end

    it "treats a month with no income as zero income" do
      sign_in(user)
      create(:spending_entry, user: user, category: food, date: Date.new(2026, 8, 10), amount: "100.00")

      get root_path(month: "2026-08-01")

      expect(response.body).to include("€-100.00").or include("-€100.00")
    end

    it "treats a month with no spending as zero spent" do
      sign_in(user)
      create(:monthly_income, user: user, month: Date.new(2026, 8, 1), amount: "2500.00")

      get root_path(month: "2026-08-01")

      expect(response.body).to include("€2,500.00")
    end

    it "shows a negative remaining amount when spending exceeds income" do
      sign_in(user)
      create(:monthly_income, user: user, month: Date.new(2026, 8, 1), amount: "100.00")
      create(:spending_entry, user: user, category: food, date: Date.new(2026, 8, 10), amount: "150.00")

      get root_path(month: "2026-08-01")

      expect(response.body).to include("€-50.00").or include("-€50.00")
    end

    it "provides per-category totals for the selected month as data for the chart" do
      sign_in(user)
      create(:spending_entry, user: user, category: food, date: Date.new(2026, 8, 10), amount: "320.50")
      create(:spending_entry, user: user, category: transport, date: Date.new(2026, 8, 12), amount: "85.20")
      create(:spending_entry, user: user, category: food, date: Date.new(2026, 7, 1), amount: "999.00")

      get root_path(month: "2026-08-01")

      data = JSON.parse(response.body[/data-dashboard-category-totals-value="([^"]*)"/, 1].then { |s| CGI.unescapeHTML(s) })
      amounts_by_category = data.to_h { |row| [ row["category"], row["amount"].to_d ] }

      expect(amounts_by_category).to eq(
        "Food" => BigDecimal("320.50"),
        "Transport" => BigDecimal("85.20")
      )
    end

    it "does not show another user's income or spending" do
      other_user = create(:user)
      other_category = create(:category, user: other_user, name: "Food")
      create(:monthly_income, user: other_user, month: Date.new(2026, 8, 1), amount: "9999.00")
      create(:spending_entry, user: other_user, category: other_category, date: Date.new(2026, 8, 10), amount: "9999.00")
      sign_in(user)

      get root_path(month: "2026-08-01")

      expect(response.body).not_to include("9999")
    end
  end
end
