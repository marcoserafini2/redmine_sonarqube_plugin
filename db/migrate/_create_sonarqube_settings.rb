class CreateSonarqubeSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :sonarqube_settings do |t|
      t.string :sonarqube_url
      t.string :sonarqube_token
      t.integer :default_tracker_id
      t.string :tracked_severities
      t.string :sonarqube_secret
      t.timestamps
    end
  end
end