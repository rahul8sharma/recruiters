class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_auth_token
	
	include Vger::Helpers::AuthenticationHelper
	
	helper_method :current_user
	helper_method :can?
  
  protected
  def set_auth_token
  	RequestStore.store[:auth_token] = session[:auth_token] || params[:auth_token]
  end
end
