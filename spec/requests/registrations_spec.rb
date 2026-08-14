require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "GET /users/new" do
    it "renders the registration form" do
      get new_user_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /users" do
    context "with valid params" do
      it "creates a user, signs them in, and redirects to the root path" do
        expect {
          post users_path, params: { user: { email_address: "new@example.com", password: "password123" } }
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(root_url)
        expect(cookies[:session_id]).to be_present
      end
    end

    context "with an already-registered email" do
      it "does not create a user and re-renders the form" do
        create(:user, email_address: "taken@example.com")

        expect {
          post users_path, params: { user: { email_address: "taken@example.com", password: "password123" } }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with a too-short password" do
      it "does not create a user and re-renders the form" do
        expect {
          post users_path, params: { user: { email_address: "new@example.com", password: "short" } }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
