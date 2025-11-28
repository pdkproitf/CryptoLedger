# frozen_string_literal: true
class AccountsController < ApplicationController
  before_action :authenticate_user!

  # TODO: Implement pagination
  def index
    accounts = Account.where(user_id: current_user.id)
    render json: build_success_json(data: accounts), status: :ok
  end
end
