# frozen_string_literal: true

FactoryBot.define do
  factory :currency do
    code { 'BTC' }
    name { 'Bitcoin' }
    precision { 8 }
    status { 'active' }
    currency_type { 'crypto' }

    trait :fiat do
      code { 'USD' }
      name { 'US Dollar' }
      precision { 2 }
      currency_type { 'fiat' }
    end

    trait :ethereum do
      code { 'ETH' }
      name { 'Ethereum' }
      precision { 18 }
    end
  end
end
