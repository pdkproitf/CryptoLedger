FactoryBot.define do
  factory :account do
    user
    currency { "BTC" }
  end
end
