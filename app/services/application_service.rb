# The base class for all service objects in the application.
# It provides a consistent interface (.call) and a standardized
# success/failure result object.
class ApplicationService
  Result = Struct.new(:success?, :payload, :errors)

  # The primary entry point for all services.
  # Creates a new instance of the service and calls its main logic.
  def self.call(...)
    new(...).call
  end

  private

  def success(payload: nil)
    Result.new(true, payload, nil)
  end

  def failure(errors:)
    # Ensure errors are always in an array for consistency.
    Result.new(false, nil, Array(errors))
  end
end
