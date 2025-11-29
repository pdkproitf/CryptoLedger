# frozen_string_literal: true

class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :transaction_type, :from_account_id, :to_account_id,
             :amount, :exchange_rate, :notes,
             :user_id, :created_at, :updated_at,
             :from_currency, :to_currency

  def from_currency
    object.from_account&.currency
  end

  def to_currency
    object.to_account&.currency
  end
end
