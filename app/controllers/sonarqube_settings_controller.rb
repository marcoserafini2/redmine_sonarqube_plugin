class SonarqubeSettingsController < ApplicationController
  layout 'admin'
  before_action :require_admin
  
  def settings
    if request.post?
      settings = params[:settings] || {}
      Setting.plugin_sonarqube_plugin = settings
      flash[:notice] = l(:notice_successful_update)
      redirect_to plugin_settings_path(id: 'sonarqube_plugin')
    else
      @settings = Setting.plugin_sonarqube_plugin || {}
    end
  end
  
  private
  
  def settings_params
    # Security: let's specify which parameters are allowed
    params.require(:settings).permit(
      :sonarqube_url, 
      :sonarqube_token, 
      :default_tracker_id, 
      :tracked_severities,
      :sonarqube_secret
      )
    end
  end