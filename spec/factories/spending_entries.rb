FactoryBot.define do
  factory :spending_entry do
    association :user
    category { association :category, user: user }
    date { Date.current }
    amount { "10.00" }
    description { "Lunch" }
  end
end
