FactoryBot.define do
  factory :spending_entry do
    association :user
    association :category
    date { Date.current }
    amount { "10.00" }
    description { "Lunch" }
  end
end
