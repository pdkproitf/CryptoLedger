# frozen_string_literal: true
class AccountsController < ApplicationController
  before_action :authenticate_user!

  # TODO: Implement pagination and sparse fieldsets
  def index
    accounts = Account.where(user_id: current_user.id)
    render json: accounts, each_serializer: AccountSerializer, status: :ok
  end
end
