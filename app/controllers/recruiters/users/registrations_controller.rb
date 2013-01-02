module Recruiters
  class Users::RegistrationsController < ApplicationController
    before_filter :redirect_if_logged_in!, :except => [:update]
    before_filter :redirect_if_not_logged_in!, :only => [:update]

    layout "recruiters/users"

    respond_to :html, :xml, :js, :json
    
    def new
      @pen = Vger::Authentication.new()
      @user = User.new
      if params[:user].present?
        @email = Base64.urlsafe_decode64(params[:user]) rescue nil
      end
      @redirect_to = params[:redirect_to]
    end

    def update
      current_user.update_yoren_attributes = true
      current_user.update_attributes!(params[:user])
      redirect_to recruiters_root_path
    end

    def create
      @redirect_to = params["redirect_to"] || default_after_signup_path

      @pen = Vger::Authentication.new
      auth_token = @pen.register(default_after_signup_url,
                                 recruiters_root_url(:trailing_slash => false),
                                 {
                                   :user => params[:user],
                                   :autoconfirm => 1
                                 })
      if @pen.errors.empty?
        @user = set_yoren_session(auth_token)

        recruiter = Vger::Spartan::Vanguard::Recruiter.find_by_user_id(@user.email)
        
        if recruiter.present?
          recruiter.update_attributes(:user_id => @user.sid)
        else
          Vger::Spartan::Vanguard::Recruiter.get(:find_or_create_current_user)
        end
        
        @user.update_yoren_attributes = true
        @user.update_attributes(params[:user].dup.extract!(:name, :phone))
        
        Vger::Herald::Notification.create(:event => "recruiters/welcome",
                                          :view_params => {
                                            :user_ids => [@user.sid],
                                            :urls => {
                                              :update_company_profile => new_recruiters_company_profile_url,
                                              :post_job => job_posting_recruiters_dashboard_index_url
                                            }
                                          })

        respond_with @user, :location => @redirect_to
      else
        @user = User.new
        respond_to do |format|
          format.json {render :json => { :error => @pen.errors}, :status => 401 }
          format.html { render :action => :new }
        end
      end
    end
  end
end
