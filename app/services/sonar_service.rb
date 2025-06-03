require 'net/http'
require 'json'
require 'uri'

class SonarService
  def search_sonar_issues(project_key)
    # Retrieving values ​​from entered parameters
    settings = Setting.plugin_redmine_sonarqube_plugin || {}
    sonar_url = settings['sonarqube_url'] + "/api/issues/search?"
    sonar_token = settings['sonarqube_token']
    default_tracker_id = settings['default_tracker_id']
    tracked_severities = settings['tracked_severities']

    # Check for missing configurations
    if sonar_url.blank? || sonar_token.blank?
      Rails.logger.error("Missing SonarQube configuration parameters")
      return []
    end

    begin
      issue_statuses_select = 'OPEN' # (optional) possible values: OPEN, CONFIRMED, FALSE_POSITIVE, ACCEPTED, FIXED
      uri = URI.parse(sonar_url)
      uri.query = URI.encode_www_form({
        components: project_key,
        severities: tracked_severities,
        issueStatuses: issue_statuses_select
      })

      # Create an HTTP GET request
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{sonar_token}"

      # Execute the request
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      # Manage the response
      if response.is_a?(Net::HTTPSuccess)
        total = JSON.parse(response.body)['total']
        Rails.logger.info("issues found: #{total}")

        # Parsing the JSON response
        issues = JSON.parse(response.body)['issues']

        # For each issue, we create an object with the necessary data
        return issues.map do |issue|
          {
            'key' => issue['key'],
            'severity' => issue['severity'],
            'component' => issue['component'],
            'line' => issue['line'],
            'message' => issue['message'],
            'author' => issue['author'],
            'type' => issue['type']
          }
        end

      else
        # Error handling in case of non-positive response
        Rails.logger.error("Error in API request to SonarQube: #{response.body}")
        return []
      end

    rescue JSON::ParserError => e
      Rails.logger.error("JSON parsing error: #{e.message}")
      puts "JSON parsing error: #{e.message}"
      return []

    rescue SocketError, Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout => e
      Rails.logger.error("Network error when connecting to SonarQube: #{e.message}")
      puts "Network error when connecting to SonarQube: #{e.message}"
      return []

    rescue StandardError => e
      Rails.logger.error("Unexpected error: #{e.message}")
      puts "Unexpected error: #{e.message}"
      return []
    end
  end
end
