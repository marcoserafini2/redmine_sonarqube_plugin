# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
post 'sonar-webhook', to: 'webhook_controller#receive'
post '/webhooks', to: 'webhooks#create', as: 'webhook_create'
post '/settings/plugin/sonarqube_plugin', to: 'settings#update_sonarqube', as: 'update_sonarqube_settings'