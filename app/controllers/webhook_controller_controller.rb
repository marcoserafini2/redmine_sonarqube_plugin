class WebhookControllerController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:receive]
  before_action :set_data
  def receive
    Rails.logger.info("execution start")
    begin
    # Retrieve the signature received from the header.
    received_signature = request.headers['X-Sonar-Webhook-HMAC-SHA256']

    # Body of the request as a string
    request_body = request.body.read

    # Parsing the JSON payload sent by the webhook
    payload = JSON.parse(request_body)

    Rails.logger.info("Received webhook with payload: #{payload.inspect}")

    project_key = payload.dig("project","key")
    Rails.logger.info("project key: #{project_key}")

    # If the payload does not contain the project key, terminate
    if project_key.blank?
      Rails.logger.error("No project key found in payload")
      render json: { message: "Project not found" }, status: :unprocessable_entity
      return
    end

    secret = @settings['sonarqube_secret']
    if secret.blank?
      Rails.logger.error("Missing SonarQube secret webhook")
      return
    end

    # Create HMAC signature using SHA256
    expected_signature = OpenSSL::HMAC.hexdigest('SHA256', secret, request_body)

    # Compare the received signature with the expected one.
    unless ActiveSupport::SecurityUtils.secure_compare(expected_signature, received_signature)
      Rails.logger.error("Invalid signature")
      render json: { message: "Invalid signature" }, status: :unauthorized
      return
    end

    # Run some logic to handle SonarQube issues
    sonar_service = SonarService.new
    issues = sonar_service.search_sonar_issues(project_key)

    default_tracker_id = @settings['default_tracker_id']

    redmine_service = RedmineService.new

    if issues.any?
      issues.each do |issue|
        redmine_service.create_redmine_issue(issue, project_key, default_tracker_id)
      end
      render json: { message: "Webhook received and issue created" }, status: :ok
      Rails.logger.info("Webhook received and issue created")
    else
      Rails.logger.info("No issues found for the project: #{project_key}")
      render json: { message: "No issues to create" }, status: :no_content
    end
    Rails.logger.info("execution success")
  
  rescue JSON::ParserError => e
    Rails.logger.error("JSON parsing error: #{e.message}")
    render json: { message: "Invalid JSON payload" }, status: :bad_request

  rescue OpenSSL::OpenSSLError => e
    Rails.logger.error("HMAC signature error: #{e.message}")
    render json: { message: "Signature verification error" }, status: :unauthorized

  rescue StandardError => e
    Rails.logger.error("Unexpected error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    render json: { message: "Internal server error" }, status: :internal_server_error
  end
end
  def set_data
    @settings = Setting.plugin_redmine_sonarqube_plugin || {}
  end
end