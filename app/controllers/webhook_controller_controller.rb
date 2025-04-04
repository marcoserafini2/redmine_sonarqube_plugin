class WebhookControllerController < ApplicationController
  
  skip_before_action :verify_authenticity_token

  def receive
    # Assuming the webhook sends a JSON payload
    payload = JSON.parse(request.body.read)

    Rails.logger.debug("Project Key: #{payload.inspect}") 

    project_key = payload["project"]&.dig("key")
    
    # Process the payload as needed
    Rails.logger.info("Received webhook with project key: #{payload.inspect}")

    # Respond with a success status
    render json: { message: "Received webhook" }, status: :ok

  end

end
