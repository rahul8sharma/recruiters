module Recruiters
  class Users::RegistrationsController < ApplicationController
    layout "recruiters/users"

    respond_to :html, :xml, :js, :json
    
    def new
      @user = User.new
    end

    def create
      @redirect_to = params["redirect_to"] || default_after_signup_path
      
      auth = Vger::Authentication.new
      auth_token = auth.register(default_after_signup_url, 'http://host.com', {
                                   :user => params[:user],
                                   :autoconfirm => 1
                                 })

      Rails.logger.ap auth_token
      
      if auth.errors.empty?
        @user = set_yoren_session(auth_token)

        #Vger::Spartan::User.get(:find_or_create_current_user)

        respond_with @user, :location => @redirect_to
      else
        @user = User.new
        respond_to do |format|
          format.json {render :json => { :error => auth.errors}, :status => 401 }
          format.html { render :action => :new }
        end
      end
    end
  end
end
