require "rails_helper"

RSpec.describe "Categories", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: user.password }
  end

  describe "when not authenticated" do
    it "redirects to sign in" do
      get categories_path

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "GET /categories" do
    it "lists only the current user's categories" do
      sign_in(user)
      mine = create(:category, user: user, name: "Food")
      create(:category, user: other_user, name: "Transport")

      get categories_path

      expect(response.body).to include(mine.name)
      expect(response.body).not_to include("Transport")
    end
  end

  describe "POST /categories" do
    it "creates a category owned by the current user" do
      sign_in(user)

      expect {
        post categories_path, params: { category: { name: "Food" } }
      }.to change(user.categories, :count).by(1)

      expect(response).to redirect_to(categories_path)
    end

    it "does not create a category with a blank name" do
      sign_in(user)

      expect {
        post categories_path, params: { category: { name: "" } }
      }.not_to change(Category, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /categories/:id/edit" do
    it "allows editing your own category" do
      sign_in(user)
      category = create(:category, user: user)

      get edit_category_path(category)

      expect(response).to have_http_status(:ok)
    end

    it "returns 404 for another user's category" do
      sign_in(user)
      category = create(:category, user: other_user)

      get edit_category_path(category)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /categories/:id" do
    it "updates your own category" do
      sign_in(user)
      category = create(:category, user: user, name: "Old name")

      patch category_path(category), params: { category: { name: "New name" } }

      expect(category.reload.name).to eq("New name")
    end

    it "returns 404 when updating another user's category" do
      sign_in(user)
      category = create(:category, user: other_user, name: "Old name")

      patch category_path(category), params: { category: { name: "New name" } }

      expect(response).to have_http_status(:not_found)
      expect(category.reload.name).to eq("Old name")
    end
  end

  describe "DELETE /categories/:id" do
    it "deletes your own category" do
      sign_in(user)
      category = create(:category, user: user)

      expect {
        delete category_path(category)
      }.to change(user.categories, :count).by(-1)
    end

    it "returns 404 when deleting another user's category" do
      sign_in(user)
      category = create(:category, user: other_user)

      expect {
        delete category_path(category)
      }.not_to change(Category, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end
