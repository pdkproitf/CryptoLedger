# frozen_string_literal: true

class TransactionsController < ApplicationController
  before_action :authenticate_user!

  # TODO: Implement pagination
  def index
    transactions = current_user.transactions
    transactions = filter_by_type(transactions) if transaction_type_filter.present?

    render json: transactions, each_serializer: TransactionSerializer, status: :ok
  end

  def create
    result = Factories::CreateTransaction.new(current_user, transaction_params).call

    if result.success?
      render json: result.data, serializer: TransactionSerializer, status: :created
    else
      render json: build_error_json(message: result.errors), status: :unprocessable_entity
    end
  end

  private

  def filter_by_type(transactions)
    transactions.where(transaction_type: transaction_type_filter)
  end

  def transaction_type_filter
    @transaction_type_filter ||= params[:type]&.split(',')&.map(&:strip)
  end

  def transaction_params
    params.require(:transaction).permit(
      :transaction_type,
      :from_account_id,
      :to_account_id,
      :amount,
      :exchange_rate,
      :transaction_hash,
      :notes
    )
  end
end
