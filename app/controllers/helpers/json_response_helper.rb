# frozen_string_literal: true

module Helpers
  module JsonResponseHelper
    def build_success_json(data: nil, meta: {})
      {
        data: data,
        meta: meta
      }
    end

    def build_error_json(message: nil, meta: {})
      {
        errors: [
          {
            detail: message,
            meta: meta
          }
        ]
      }
    end
  end
end
