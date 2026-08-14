require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user, email_address: "person@example.com", password: "password123") }

  describe "GET /session/new" do
    it "renders the sign in form" do
      get new_session_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /session" do
    context "with valid credentials" do
      it "signs the user in and redirects to the root path" do
        post session_path, params: { email_address: user.email_address, password: "password123" }

        expect(response).to redirect_to(root_url)
        expect(cookies[:session_id]).to be_present
      end
    end

    context "with invalid credentials" do
      it "does not sign the user in and redirects back to the sign in form" do
        post session_path, params: { email_address: user.email_address, password: "wrong" }

        expect(response).to redirect_to(new_session_path)
        expect(cookies[:session_id]).to be_blank
      end
    end
  end

  describe "DELETE /session" do
    it "signs the user out" do
      post session_path, params: { email_address: user.email_address, password: "password123" }

      delete session_path

      expect(response).to redirect_to(new_session_path)
      expect(user.sessions.count).to eq(0)
    end
  end
end
