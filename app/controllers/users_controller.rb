class UsersController < ApplicationController
  layout "users"
  before_filter :authenticate_user!, :only => [ :password_settings, :index ]
  
  def index
    params[:search] ||= {}
    params[:search] = params[:search].select{|key,val| val.present? }
    search_params = params[:search].dup
    name = search_params.delete :name
    email = search_params.delete :email
    conditions = {
      methods: [:company_ids, :type, :assessment_ids],
      root: :user,
      query_options: search_params,
      page: params[:page], per: 10
    }
    conditions[:scopes] = {}
    conditions[:scopes][:name_like] = name if name
    conditions[:scopes][:email_like] = email if email
    @users = Vger::Resources::User.where(conditions)
    render layout: "companies"
  end

  def login
    if request.post?
      begin
        token = sign_in(params[:user])
        RequestStore.store[:auth_token] = token.token
        response = Vger::Resources::User.current()
        if response.respond_to?(:error) && response.send(:error).present?
          flash[:error] = response.error
          redirect_to login_path and return
        end
        current_user = response
        redirect_user
      rescue OAuth2::Error => e
        json = JSON.parse e.response.response.body
        flash[:error] = json["error"]
      rescue Faraday::Unauthorized => e
        flash[:error] = e.response[:body][:data][:error]
      end
    else
      redirect_user
    end
  end

  def logout
    sign_out()
    redirect_to after_sign_out_path and return
  end

  def forgot_password
  end

  # redenr companies layout and header if user belongs to a company
  def password_settings
    if current_user.respond_to?(:company_id) && current_user.company_id.present?
      @company = Vger::Resources::Company.find(current_user.company_id)
      render :layout => "companies"
    end
  end

  def link_sent
  end

  # Refering to https://github.com/plataformatec/devise/issues/1955
  # devise doesn't check for blank new password
  # the workaround is to check the password in the params and render error if password is left blank
  def update_password_settings
    if params[:user][:password].blank?
      flash[:error] = "Password can't be blank."
      redirect_to password_settings_path
    elsif params[:user][:password]!=params[:user][:password_confirmation]
      flash[:error] = "Password and Confirm Password don't match."
      redirect_to password_settings_path
    else
      @user = Vger::Resources::User.update_password(params[:user])
      if @user.error_messages && @user.error_messages.empty?
        flash[:notice] = "Password settings saved successfully."
        sign_in(:auth_token => @user.authentication_token)
        redirect_user
      else
        flash[:error] = @user.error_messages.join("<br/>").html_safe
        redirect_to password_settings_path
      end
    end
  end

  def send_reset_password
    @user = Vger::Resources::User.send_reset_password_instructions(params[:user])
    if @user.error_messages && @user.error_messages.empty?
      render :action => :link_sent
    else
      # flash[:error] = @user.error_messages.join("<br/>").html_safe
      flash[:error] = "Please provide the email address associated with your Jombay Account to continue"
      redirect_to forgot_password_path
    end
  end

  def reset_password
    @user = Vger::Resources::User.where(:root => :user, :query_options => { :reset_password_token => params[:reset_password_token] }).all[0]
    if !@user
      if params[:activate]
        flash[:error] = "Activation link has expired."
      else
        flash[:error] = "Reset password link has expired."
      end
      redirect_to(root_url) and return
    end
    if params[:activate]
      render :action => :activate
    end
  end

  def confirm
    @user = Vger::Resources::User.confirm(:confirmation_token => params[:confirmation_token])
    if @user.error_messages.present?
      flash[:error] = "Oops! Your verification link has already been used or has expired. If you have not yet verified your email address, please email us at contact@jombay.com and we'll help you set-up your account!"
      redirect_to(root_url)
    else
      sign_in(:auth_token => @user.authentication_token)
      redirect_user
    end
  end

  def activate
    if request.put?
      @user = Vger::Resources::User.reset_password_by_token(params[:user], :root => :user)
      if @user.error_messages && @user.error_messages.empty?
        flash[:notice] = "#{@user.name}, Your account has been successfully activated!"
        sign_in(:auth_token => @user.authentication_token)
        redirect_user
      else
        flash[:error] = @user.error_messages.join("<br/>").html_safe
        redirect_to activate_account_path(:reset_password_token => params[:user][:reset_password_token])
      end
    else
      @user = Vger::Resources::User.where(:root => :user, :query_options => { :reset_password_token => params[:reset_password_token] }).all[0]
    end
  end

  def update_password
    @user = Vger::Resources::User.reset_password_by_token(params[:user])
    if @user.error_messages && @user.error_messages.empty?
      flash[:notice] = "Password was reset successfully!"
      sign_in(:auth_token => @user.authentication_token)
      redirect_user
    else
      flash[:error] = @user.error_messages.join("<br/>").html_safe
      redirect_to reset_password_path(:reset_password_token => params[:user][:reset_password_token])
    end
  end

  protected

  def redirect_user
    if current_user
      if current_user.type == "Candidate"
        flash.clear
        flash[:error] = "You are not authorized to access this page."
        sign_out
        redirect_to root_path
      else
        redirect_to after_sign_in_path_for, :notice => flash[:notice]
      end
    end
  end
end
