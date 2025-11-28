# frozen_string_literal: true

module SimpleAuthentication
  extend ActiveSupport::Concern

  private

  def authenticate_user!
    user_id = request.headers['user-id']
    @current_user = User.find_by(id: user_id)

    render json: build_error_json(message: 'Unauthorized'), status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end
end
