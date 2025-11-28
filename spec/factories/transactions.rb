FactoryBot.define do
  factory :transaction do
    association :user
    transaction_type { 'deposit' }
    from_account { nil }
    to_account { nil }
    amount { "1000.00000000" }
    exchange_rate { nil }
    transaction_hash { "0xabc123def456" }
    notes { "Initial deposit" }
  end
end
