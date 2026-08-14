require "rails_helper"

RSpec.describe "SpendingEntries", type: :request do
  let(:user) { create(:user) }
  let(:category) { create(:category, user: user) }
  let(:other_user) { create(:user) }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: user.password }
  end

  describe "when not authenticated" do
    it "redirects to sign in" do
      get spending_entries_path

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "GET /spending_entries" do
    it "shows only the current user's entries for the selected month" do
      sign_in(user)
      in_month = create(:spending_entry, user: user, category: category, date: Date.new(2026, 8, 10), description: "In month")
      create(:spending_entry, user: user, category: category, date: Date.new(2026, 7, 31), description: "Adjacent month")
      other_users_category = create(:category, user: other_user)
      create(:spending_entry, user: other_user, category: other_users_category, date: Date.new(2026, 8, 10), description: "Other user")

      get spending_entries_path(month: "2026-08-01")

      expect(response.body).to include(in_month.description)
      expect(response.body).not_to include("Adjacent month")
      expect(response.body).not_to include("Other user")
    end

    it "formats amounts and the total in euros" do
      sign_in(user)
      create(:spending_entry, user: user, category: category, date: Date.new(2026, 8, 10), amount: "23.50")

      get spending_entries_path(month: "2026-08-01")

      expect(response.body).to include("€23.50")
    end

    it "defaults to the current month when no month param is given" do
      sign_in(user)

      get spending_entries_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /spending_entries" do
    it "creates an entry owned by the current user" do
      sign_in(user)

      expect {
        post spending_entries_path, params: { spending_entry: {
          date: "2026-08-10", amount: "23.50", description: "Lunch", category_id: category.id
        } }
      }.to change(user.spending_entries, :count).by(1)

      expect(response).to redirect_to(spending_entries_path(month: "2026-08-01"))
    end

    it "does not create an entry with another user's category" do
      sign_in(user)
      other_users_category = create(:category, user: other_user)

      expect {
        post spending_entries_path, params: { spending_entry: {
          date: "2026-08-10", amount: "23.50", description: "Lunch", category_id: other_users_category.id
        } }
      }.not_to change(SpendingEntry, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "does not create an entry with a negative amount" do
      sign_in(user)

      expect {
        post spending_entries_path, params: { spending_entry: {
          date: "2026-08-10", amount: "-5", description: "Lunch", category_id: category.id
        } }
      }.not_to change(SpendingEntry, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /spending_entries/:id/edit" do
    it "returns 404 for another user's entry" do
      sign_in(user)
      other_users_category = create(:category, user: other_user)
      entry = create(:spending_entry, user: other_user, category: other_users_category)

      get edit_spending_entry_path(entry)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /spending_entries/:id" do
    it "updates your own entry" do
      sign_in(user)
      entry = create(:spending_entry, user: user, category: category, description: "Old")

      patch spending_entry_path(entry), params: { spending_entry: { description: "New" } }

      expect(entry.reload.description).to eq("New")
    end

    it "returns 404 when updating another user's entry" do
      sign_in(user)
      other_users_category = create(:category, user: other_user)
      entry = create(:spending_entry, user: other_user, category: other_users_category, description: "Old")

      patch spending_entry_path(entry), params: { spending_entry: { description: "New" } }

      expect(response).to have_http_status(:not_found)
      expect(entry.reload.description).to eq("Old")
    end
  end

  describe "DELETE /spending_entries/:id" do
    it "deletes your own entry" do
      sign_in(user)
      entry = create(:spending_entry, user: user, category: category)

      expect {
        delete spending_entry_path(entry)
      }.to change(user.spending_entries, :count).by(-1)
    end

    it "returns 404 when deleting another user's entry" do
      sign_in(user)
      other_users_category = create(:category, user: other_user)
      entry = create(:spending_entry, user: other_user, category: other_users_category)

      expect {
        delete spending_entry_path(entry)
      }.not_to change(SpendingEntry, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end
