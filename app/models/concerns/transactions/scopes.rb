# frozen_string_literal: true

module Transactions
  module Scopes
    extend ActiveSupport::Concern

    TRANSACTION_TYPES = {
      trade: 'trade',
      trading_fee: 'trading_fee',
      deposit: 'deposit',
      withdrawal: 'withdrawal'
    }.freeze
  end
end
