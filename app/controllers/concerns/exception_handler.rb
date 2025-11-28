# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found_response

    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid_response
  end

  private

  def record_not_found_response(exception)
    render json: build_error_json(message: exception.message), status: :not_found
  end

  def record_invalid_response(exception)
    render json: build_error_json(message: exception.record.errors.full_messages.join(', ')), status: :unprocessable_entity
  end
end
