class ApplicationController < ActionController::API
  include ApiExceptionHandler
  include Authenticatable
  include Authorizable

  before_action :set_current_context

  private

  def set_current_context
    Current.correlation_id = request.request_id
  end
end
