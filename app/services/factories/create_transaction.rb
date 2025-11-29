# frozen_string_literal: true

module Factories
  class CreateTransaction
    attr_reader :user, :params, :errors

    def initialize(user, params)
      @user = user
      @params = params
      @errors = []
    end

    def call
      validate_params
      return ServiceResult.new(errors:) if errors.any?

      transaction = build_transaction
      if transaction.save
        ServiceResult.new(data: transaction)
      else
        ServiceResult.new(errors: transaction.errors.full_messages)
      end
    rescue ArgumentError => e
      ServiceResult.new(errors: [e.message])
    end

    private

    def validate_params
      validate_from_account
    end

    def validate_from_account
      account = user.accounts.find_by(id: params[:from_account_id])
      validate_from_account_ownership(account)
      validate_sufficient_balance(account) if account && debit_transaction?
    end

    def validate_from_account_ownership(account)
      @errors << 'Invalid from account!' unless account
    end

    def validate_sufficient_balance(account)
      return if account.balance >= params[:amount].to_f

      @errors << "Insufficient balance in from account. Available: #{account.balance}, Required: #{params[:amount]}"
    end

    def build_transaction
      user.transactions.new(
        transaction_type: params[:transaction_type],
        from_account_id: params[:from_account_id],
        to_account_id: params[:to_account_id],
        amount: params[:amount],
        exchange_rate: params[:exchange_rate],
        notes: params[:notes]
      )
    end

    def debit_transaction?
      %w[withdrawal trade].include?(params[:transaction_type])
    end
  end
end
