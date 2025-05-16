class SonarqubeSettings < ApplicationRecord
  validates :sonarqube_url, presence: true
  validates :sonarqube_token, presence: true
  validates :default_tracker_id, presence: true
  validates :tracked_severities, presence: true
  validates :sonarqube_secret, presence: true
end


