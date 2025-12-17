class ApplicationController < ActionController::API
  include ::ExceptionHandler
  include ::SimpleAuthentication
  include ::Helpers::JsonResponseHelper
end
