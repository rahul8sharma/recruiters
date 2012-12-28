module Recruiters
  class Users::PasswordsController < ApplicationController
    layout "recruiters/users"
    
    def new
      @pen = Vger::Authentication.new
    end

    # POST /resource/password
    def create
      @pen = Vger::Authentication.new
      @pen.forgot_password(request.env['HTTP_REFERER'], recruiters_root_url(:trailing_slash => false),{:user => params[:user]})
      user = User.find_by_email(params[:user][:email])
      if user.present?
        Rails.logger.ap user.reset_password_token
        Vger::Herald::Notification.create(:event => "recruiters/reset_password", :view_params => {:user_ids => [user.sid], :urls => {:reset_password => edit_user_password_url(:reset_password_token => user.reset_password_token)}})
      end
      respond_to do |format|
        if @pen.errors
          format.json {render :json => { :error => @pen.errors}, :status => 422 }
          format.html {render :action => :new}
        else
          format.html {redirect_to after_sending_reset_password_instructions_path, :flash => {:info => "Password reset instructions have been sent to your email!"}}
          format.json {render :json => {}, :status => 201 }
        end
      end
    end

    # GET /resource/password/edit?reset_password_token=abcdef
    def edit
      @pen = Vger::Authentication.new
      @user = User.new
      @user.reset_password_token = params[:reset_password_token]
    end

    # PUT /resource/password
    def update
      @pen = Vger::Authentication.new
      @pen.change_password(:user => params[:user])

      if @pen.errors
        respond_to do |format|
          format.json {render :json => { :error => @pen.errors}, :status => 422 }
        end
      else
        respond_to do |format|
          format.html { redirect_to after_sending_reset_password_instructions_path, :success => "Password successfully reset." }
          format.json {render :json => {}, :status => 201 }
        end  
      end
    end

    protected

    def after_reset_password_path
      after_sending_reset_password_instructions_path
    end

    def after_sending_reset_password_instructions_path
      params['redirect_to'] || new_user_session_path
    end
    
    # The path used after sending reset password instructions
    def after_sending_reset_password_instructions_path_for(resource_name)
      params['redirect_to'] || new_session_path(resource_name)
    end

  end
end
