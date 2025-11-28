# frozen_string_literal: true

class TransactionsController < ApplicationController
  before_action :authenticate_user!

  # TODO: Implement pagination
  def index
    transactions = current_user_transactions
    transactions = filter_by_type(transactions) if transaction_type_filter.present?

    render json: build_success_json(data: transactions), status: :ok
  end

  private

  def current_user_transactions
    Transaction.where(user_id: current_user.id)
  end

  def filter_by_type(transactions)
    transactions.where(transaction_type: transaction_type_filter)
  end

  def transaction_type_filter
    @transaction_type_filter ||= params[:type]&.split(',')&.map(&:strip)
  end
end
