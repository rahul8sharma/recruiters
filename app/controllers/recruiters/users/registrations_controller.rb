module Recruiters
  class Users::RegistrationsController < ApplicationController
    layout "recruiters/users"

    respond_to :html, :xml, :js, :json
    
    def new
      @user = User.new
    end

    def update
      current_user.update_yoren_attributes = true
      current_user.update_attributes!(params[:user])
      redirect_to recruiters_root_path
    end

    def create
      @redirect_to = params["redirect_to"] || default_after_signup_path
      
      auth = Vger::Authentication.new
      auth_token = auth.register(default_after_signup_url, recruiters_root_url(:trailing_slash => false), {
                                   :user => params[:user],
                                   :autoconfirm => 1
                                 })

      if auth.errors.empty?
        @user = set_yoren_session(auth_token)
        
        Vger::Spartan::Vanguard::Recruiter.get(:find_or_create_current_user)

        #@user.update_yoren_attributes = true
        @user.update_attributes(params[:user].dup.extract!(:name, :phone))

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
