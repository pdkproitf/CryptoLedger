# frozen_string_literal: true

class Api::V1::TransactionsController < ApplicationController
  before_action :authenticate_user!

  # TODO: Implement pagination
  def index
    result = Transactions::FilterService.new(
      current_user,
      filter_params
    ).call

    if result.success?
      render json: result.data, each_serializer: TransactionSerializer, status: :ok
    else
      render json: build_error_json(message: result.errors), status: :unprocessable_entity
    end
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

  def filter_params
    params[:filters] ||= {}
    {
      type: params[:filters][:type],
      currency: params[:filters][:currency]
    }
  end

  def transaction_params
    params.require(:transaction).permit(
      :transaction_type,
      :from_account_id,
      :to_account_id,
      :amount,
      :exchange_rate,
      :notes
    )
  end
end
