require "rails_helper"

RSpec.describe SpendingEntry, type: :model do
  it "has a valid factory" do
    expect(build(:spending_entry)).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:category) }
  end

  describe "validations" do
    subject { build(:spending_entry) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
  end

  describe "monetary precision" do
    it "stores the amount as a BigDecimal, not a Float" do
      entry = create(:spending_entry, amount: "23.50")

      expect(entry.reload.amount).to eq(BigDecimal("23.50"))
      expect(entry.amount).to be_a(BigDecimal)
    end

    it "preserves precision across repeated additions that trip up floats" do
      entries = 3.times.map { create(:spending_entry, amount: "0.10") }

      total = entries.sum(&:amount)

      expect(total).to eq(BigDecimal("0.30"))
    end
  end

  describe "deleting a category with spending entries" do
    it "is blocked and keeps the spending entry intact" do
      entry = create(:spending_entry)

      expect { entry.category.destroy }.not_to change(SpendingEntry, :count)
      expect(entry.category.errors[:base]).to be_present
    end
  end
end
