class ApplicationController < ActionController::API
  include ::ExceptionHandler
  include ::JsonResponseHelper
  include ::SimpleAuthentication
end
