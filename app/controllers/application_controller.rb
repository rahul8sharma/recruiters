class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_auth_token
	
	include Vger::Helpers::AuthenticationHelper
	
	rescue_from Faraday::Unauthorized, :with => :unauthorized
	rescue_from Faraday::ResourceNotFound, :with => :resource_not_found
	rescue_from Vger::Errors::InvalidAuthenticationException, :with => :invalid_authentication
	
	helper_method :current_user
	helper_method :can?
  
  protected
  def set_auth_token
  	RequestStore.store[:auth_token] = session[:auth_token] || params[:auth_token]
  end
  
  def unauthorized
    flash[:notice] = "You must be logged in to visit this page"
    redirect_to login_path
  end
  
  def resource_not_found
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
    end
  end
  
  def invalid_authentication(e)
    session[:auth_token] = nil
    flash[:notice] = e.message
    redirect_to login_path
  end
end
