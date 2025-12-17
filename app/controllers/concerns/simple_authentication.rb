# frozen_string_literal: true

# This module provides a simple authentication mechanism based on a user ID
# passed in the request headers. It defines methods to authenticate the user
# and retrieve the current user.
# TODO: Replace with a more secure authentication such as JWT or OAuth.
module SimpleAuthentication
  extend ActiveSupport::Concern

  private

  def authenticate_user!
    user_id = request.headers['user-id']
    @current_user = User.find_by(id: user_id)

    render json: build_error_json(message: I18n.t('errors.unauthorized')), status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end
end
