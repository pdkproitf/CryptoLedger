# frozen_string_literal: true

module Transactions
  class FilterService
    attr_reader :filters, :current_user

    def initialize(current_user, filters = {})
      @current_user = current_user
      @filters = filters
    end

    def call
      transactions = current_user.transactions
      transactions = filter_by_type(transactions) if type_filter.present?
      transactions = filter_by_currency(transactions) if currency_filter.present?
      ServiceResult.new(data: transactions)
    rescue ArgumentError, ActiveRecord::StatementInvalid => e
      # log or notify here
      ServiceResult.new(errors: [e.message])
    end

    private

    def filter_by_type(transactions)
      transactions.where(transaction_type: type_filter)
    end

    def filter_by_currency(transactions)
      transactions.joins(:from_account, :to_account).where(accounts: { currency: currency_filter })
    end

    def type_filter
      @type_filter ||= parse_comma_separated(@filters[:type])
    end

    def currency_filter
      @currency_filter ||= parse_comma_separated(@filters[:currency])&.map(&:upcase)
    end

    def parse_comma_separated(value)
      value&.split(',')&.map(&:strip)&.presence
    end
  end
end
