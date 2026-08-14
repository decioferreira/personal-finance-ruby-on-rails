require "rails_helper"

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_uniqueness_of(:email_address).case_insensitive }
    it { is_expected.to have_secure_password }
    it { is_expected.to validate_length_of(:password).is_at_least(8) }
  end

  describe "email_address normalization" do
    it "downcases and strips the email address before saving" do
      user = create(:user, email_address: "  Person@Example.COM  ")

      expect(user.email_address).to eq("person@example.com")
    end
  end
end
