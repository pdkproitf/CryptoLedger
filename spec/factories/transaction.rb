# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    user
    transaction_type { 'deposit' }
    amount { 100.0 }
    exchange_rate { 1.0 }
    to_account { association :account, user: user }

    trait :deposit do
      transaction_type { 'deposit' }
      from_account { nil }
      to_account { association :account, user: user }
    end

    trait :withdrawal do
      transaction_type { 'withdrawal' }
      from_account { association :account, user: user }
      to_account { nil }
    end

    trait :trade do
      transaction_type { 'trade' }
      from_account { association :account, user: user, currency: 'BTC' }
      to_account { association :account, user: user, currency: 'ETH' }
      amount { 0.5 }
      exchange_rate { 15.0 }
    end
  end
end
