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

    included do
      TRANSACTION_TYPES.values.each do |transaction_type|
        scope transaction_type, -> { where(transaction_type: transaction_type) }

        define_method "#{transaction_type}?" do
          self.transaction_type == transaction_type
        end
      end
    end
  end
end
