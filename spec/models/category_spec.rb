require "rails_helper"

RSpec.describe Category, type: :model do
  it "has a valid factory" do
    expect(build(:category)).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject { create(:category) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:user_id).case_insensitive }
  end

  it "allows different users to have categories with the same name" do
    category_a = create(:category, name: "Food")
    category_b = build(:category, name: "Food")

    expect(category_b).to be_valid
    expect(category_a.user_id).not_to eq(category_b.user_id)
  end
end
