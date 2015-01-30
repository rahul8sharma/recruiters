class CompanySettingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:id]) }

  layout "companies"

  before_filter :get_company

  def settings
  end

  def account
  end

  def company
  end

  def statistics
  end

  def competencies
  end

  def create_competencies
  end

  def competency
  end

  def user_settings
    params[:users] ||= {}
    @users = Vger::Resources::Admin.where(:query_options => {:company_id => @company.id}, :page => params[:page],
      :per => 10,methods: [:reset_password_token]).all
  end

  def remove_users
    params[:users] ||= {}
    @users = Vger::Resources::Admin.where(:query_options => {:company_id => @company.id}, :page => params[:page], :per => 10).all
    if params[:users].empty?
      flash[:error] = "Please select at least one user to remove"
    else
    end
    render :action => :user_settings
  end

  def confirm_remove_users
    params[:user_ids].split("|").each do |user_id,on|
      Vger::Resources::Admin.destroy_existing(user_id)
    end
    flash[:notice] = "Users removed successfully."
    redirect_to user_settings_company_path(@company)
  end

  def add_users
    if request.put?
      users = {}
      errors = {}
      params[:users] ||= {}
      params[:users].reject!{|key,data| data[:email].blank? && data[:name].blank?}
      params[:users] = Hash[params[:users].collect{|key,data| [data[:email], data] }]
      if params[:users].empty?
        flash[:error] = "Please add at least one user to proceed."
        render :action => :add_users and return
      end
      if params[:users].find{|key,data| data[:name].blank? || data[:email].blank? }.present?
        flash[:error] = "Please enter full name as well as email id of the users you want to add."
        render :action => :add_users and return
      end
      params[:users].each do |key,user_data|
        user = Vger::Resources::User.where(:query_options => { :email => user_data[:email] }).all[0]
        if user
          user_data[:id] = user.id
          users[user.id] = user_data
        else
          user_data[:notify] = user_data[:notify].present?
          user = Vger::Resources::Admin.create(user_data)
          if user.error_messages.present?
            errors[user.email] ||= []
            errors[user.email] |= user.error_messages
          else
            user_data[:id] = user.id
            users[user.id] = user_data
          end
        end
        unless errors.empty?
          flash[:error] = "Invalid data. Please ensure that email addresses provided are in the correct format."
          render :action => :add_users and return
        end
      end
      flash[:notice] = "New users successfully added. Instructions to login have been emailed to the users."
      redirect_to user_settings_company_path(@company)
    else
    end
  end

  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:id], :include => [ :subscription ], :methods => [ :assessment_statistics ])
  end
end

