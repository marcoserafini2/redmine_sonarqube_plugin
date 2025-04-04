# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
post 'sonarqube-webhook', to: 'webhook_controller#receive'
