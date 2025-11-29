# frozen_string_literal: true

class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :transaction_type, :from_account_id, :to_account_id,
             :amount, :exchange_rate, :transaction_hash, :notes,
             :user_id, :created_at, :updated_at
end
