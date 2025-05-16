Redmine::Plugin.register :sonarqube_plugin do
  name 'SonarQube Plugin '
  author 'Marco Serafini'
  description 'Redmine Plugin for SonarQube Webhooks & Issue Sync'
  version '0.0.2'
  url 'https://github.com/marcoserafini2/redmine_sonarqube_plugin'
  author_url 'https://github.com/marcoserafini2/'
  
  requires_redmine version_or_higher: '6.0.0'
 
  # plugin settings
  settings default: {
    'sonarqube_url' => '',
    'sonarqube_token' => '',
    'default_tracker_id' => '',
    'tracked_severities' => '',
    'sonarqube_secret' => '',
    }, partial: 'settings/sonarqube_settings'
end
