require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    context "when authenticated" do
      it "returns http success" do
        user = create(:user)
        post session_path, params: { email_address: user.email_address, password: user.password }

        get root_path

        expect(response).to have_http_status(:success)
      end
    end

    context "when not authenticated" do
      it "redirects to the sign in page" do
        get root_path

        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
