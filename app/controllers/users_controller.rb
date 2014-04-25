class UsersController < ApplicationController
  layout "users"
  before_filter :authenticate_user!, :only => [ :password_settings ]
  
  def login
    redirect_to after_sign_in_path_for if current_user
    if request.post?
      begin
        sign_in(params[:user])
      rescue Faraday::Unauthorized => e
        flash[:error] = e.response[:body][:data][:error]
      end
    else
    end
  end
  
  def logout
    sign_out()
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
    else
      @user = Vger::Resources::User.update_password(params[:user])
      if @user.error_messages && @user.error_messages.empty?
        flash[:notice] = "Password settings saved successfully."
        sign_in(:auth_token => @user.authentication_token)
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
      flash[:error] = @user.error_messages.join("<br/>").html_safe
      redirect_to forgot_password_path
    end
  end
  
  def reset_password
    @user = Vger::Resources::User.where(:root => :user, :query_options => { :reset_password_token => params[:reset_password_token] }).all[0]  
    if params[:activate]
      if !@user
        redirect_to(root_url, notice: "Invalid reset password token")  and return
      end
      render :action => :activate 
    end
  end
  
  def confirm
    @user = Vger::Resources::User.confirm(:confirmation_token => params[:confirmation_token])
    if @user.error_messages.present?
      redirect_to(root_url, notice: "Invalid confirmation_token token")
    else
      redirect_to(login_path)
    end
  end
  
  def activate
    if request.put?
      @user = Vger::Resources::User.reset_password_by_token(params[:user], :root => :user)
      if @user.error_messages && @user.error_messages.empty?
        flash[:notice] = "#{@user.name}, Your account has been successfully activated!"
        sign_in(:auth_token => @user.authentication_token)
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
    else
      flash[:error] = @user.error_messages.join("<br/>").html_safe
      redirect_to reset_password_path(:reset_password_token => params[:user][:reset_password_token])
    end
  end
end
