module Recruiters
  class Users::SessionsController < ApplicationController
    layout "recruiters/users"
    
    respond_to :html, :xml, :js, :json
    
    before_filter :redirect_if_logged_in!, :except => :destroy
    
    def new
      @user = User.new
      auth = Vger::Authentication.new
      @redirect_to = if params[:redirect_to].present?
                       params[:redirect_to]
                     else
                       default_after_signup_path
                     end
      respond_to do |format|
        format.js {}
        format.html
      end
    end

    # POST /resource/sign_in
    def create
      @user = User.new(params[:user])
      auth = Vger::Authentication.new
      auth_token = auth.signin(:user => params[:user])
      @redirect_to = params[:redirect_to] || env['HTTP_REFERER'] || default_after_signin_path
      if auth.errors.empty?
        @user = set_yoren_session(auth_token)
        #flash[:notice] = "Successfully logged in."
        respond_with @user, :location => @redirect_to
      else
        respond_to do |format|
          format.json {render :json => { :error => auth.errors}, :status => 401 }
          format.html { render :action => :new }
        end
      end
    end

    # GET /resource/sign_out
    def destroy
      #    signed_in = signed_in?(resource_name)
      #    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      #    set_flash_message :notice, :signed_out if signed_in

      session[:yoren_user] = nil
      session[:user] = nil

      # We actually need to hardcode this, as Rails default responder doesn't
      # support returning empty response on GET request
      redirect_to after_logout_path
    end

    protected

    def after_logout_path
      recruiters_root_path(:trailing_slash => false)
    end
  end

end
