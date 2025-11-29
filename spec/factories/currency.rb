# frozen_string_literal: true

FactoryBot.define do
  factory :currency do
    currency { 'BTC' }
    name { 'Bitcoin' }
    precision { 8 }
    status { 'active' }
    currency_type { 'crypto' }

    trait :fiat do
      currency { 'USD' }
      name { 'US Dollar' }
      precision { 2 }
      currency_type { 'fiat' }
    end

    trait :ethereum do
      currency { 'ETH' }
      name { 'Ethereum' }
      precision { 18 }
    end
  end
end
