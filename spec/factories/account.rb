FactoryBot.define do
  factory :account do
    currency { "USD" }
    user
  end
end