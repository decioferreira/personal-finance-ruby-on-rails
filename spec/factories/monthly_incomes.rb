FactoryBot.define do
  factory :monthly_income do
    association :user
    month { Date.current.beginning_of_month }
    amount { "2500.00" }
  end
end
