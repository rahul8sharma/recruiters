class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_auth_token
  
  include Vger::Helpers::AuthenticationHelper
  include ApplicationHelper
  
  rescue_from Faraday::Unauthorized, :with => :unauthorized
  rescue_from Faraday::ResourceNotFound, :with => :resource_not_found
  rescue_from Vger::Errors::InvalidAuthenticationException, :with => :invalid_authentication
  rescue_from Her::Errors::ParseError, :with => :parse_error
  
  helper_method :current_user
  helper_method :current_role
  helper_method :can?
  helper_method :is_superuser?, :is_jit_user?, :is_company_manager?, :is_admin?
  
  # redirect user according to type of the user
  # keep the flash message before redirecting to display any errors/warnings
  def after_sign_in_path_for()
    flash.keep
    return params[:redirect_to] if params[:redirect_to].present?
    redirect_user_path
  end
  
  protected
  
  def redirect_user_path
    if current_user
      self.send "redirect_#{current_role.underscore}"
    else
      login_path(:redirect_to => request.fullpath)
    end
  end
  
  def current_role
    @role ||= current_user.role_names.select do |role|
      [
        Vger::Resources::Role::RoleName::SUPER_ADMIN,
        Vger::Resources::Role::RoleName::JIT,
        Vger::Resources::Role::RoleName::COMPANY_MANAGER,
        Vger::Resources::Role::RoleName::ADMIN
      ].include?(role)
    end.first
  end
  
  def set_auth_token
    token = get_token(params)
    RequestStore.store[:auth_token] = (token ? token.token : nil)
  end
  
  def is_superuser?
    current_user and (is_jit_user? || current_role == Vger::Resources::Role::RoleName::SUPER_ADMIN)
  end
  
  def is_jit_user?
    current_user and current_role == Vger::Resources::Role::RoleName::JIT
  end
  
  def is_company_manager?
    current_user and current_role == Vger::Resources::Role::RoleName::COMPANY_MANAGER
  end
  
  def is_admin?
    current_user and current_role == Vger::Resources::Role::RoleName::ADMIN
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
  
  # Redirect to after sign in path if user tries to access a non-existing resource
  def resource_not_found
    flash[:error] = "This page does not exist."
    redirect_to request.env['HTTP_REFERER'] || redirect_user_path
  end
  
  # set session[:auth_token] to nil
  # redirect to login_path
  def invalid_authentication(e)
    session[:auth_token] = nil
    flash[:error] = e.message
    redirect_to login_path(:redirect_to => request.fullpath)
  end
  
  # Handle parse error thrown by vger when the response from the server is invalid
  def parse_error(e)
    flash[:error] = "Something went wrong."
    redirect_to request.env['HTTP_REFERER'] || redirect_user_path
  end
  
  def check_superuser
    if !is_superuser?
      flash[:error] = "You are not authorized to access this page."
      redirect_to root_url and return
    end 
  end
  
  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
  
  def authorize_user!(company_id)
    if is_superuser? || is_jit_user?
      return true
    elsif is_company_manager? && current_user.company_ids.include?(company_id.to_i)
      return true
    elsif is_admin? && current_user.company_id.to_i == company_id.to_i  
      return true 
    else
      redirect_to redirect_user_path
    end
  end
end
