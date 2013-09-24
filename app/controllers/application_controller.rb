class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_auth_token
  
  include Vger::Helpers::AuthenticationHelper
  
  rescue_from Faraday::Unauthorized, :with => :unauthorized
  rescue_from Faraday::ResourceNotFound, :with => :resource_not_found
  rescue_from Vger::Errors::InvalidAuthenticationException, :with => :invalid_authentication
  
  helper_method :current_user
  helper_method :can?
  
  # redirect user according to type of the user
  # keep the flash message before redirecting to display any errors/warnings
  def after_sign_in_path_for()
    flash.keep
    case current_user.type
      when "SuperAdmin"
        params[:redirect_to] || companies_path
      when "Admin"
        params[:redirect_to] || company_assessments_path(current_user.company_id)  
      else
        params[:redirect_to] || root_path        
    end    
  end

  
  protected
  def set_auth_token
    RequestStore.store[:auth_token] = session[:auth_token] || params[:auth_token]
  end
  
  
  # catch unauthorized exception from Faraday
  # if user is logged in the error is because of cancan
  # set session[:redirect_to] - nil to avoid redirect loop
  # redirect to after_sign_in_path_for  
  # else
  # set session[:redirect_to] = request.fullpath
  # and redirect to login path
  def unauthorized
    if current_user
      flash[:error] = "You are not authorized to access this page."
      redirect_to after_sign_in_path_for()
    else
      flash[:error] = "You must be logged in to visit this page."
      redirect_to login_path(:redirect_to => request.fullpath)
    end
  end
  
  def resource_not_found
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
    end
  end
  
  # set session[:auth_token] to nil
  # redirect to login_path
  def invalid_authentication(e)
    session[:auth_token] = nil
    flash[:error] = e.message
    redirect_to login_path
  end
end
