module ApiExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      render_not_found(e.model)
    end
  end

  private

  def render_not_found(message = "Resource")
    render json: { success: false, error: "#{message} not found" }, status: :not_found
  end

  def render_unprocessable_entity(message)
    render json: { success: false, error: message }, status: :unprocessable_entity
  end

  def render_unauthorized(message = "Unauthorized")
    render json: { success: false, error: message }, status: :unauthorized
  end
end
