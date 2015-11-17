class CompanySettingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_user!(params[:id]) }

  layout "companies"

  before_filter :get_company
  before_filter :get_company_managers, only: [:company_managers, :remove_company_managers]

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
    @users = Vger::Resources::User.where(
      joins: [:roles],
      query_options: {
        company_id: @company.id,
        "roles.name" => Vger::Resources::Role::RoleName::ADMIN
      }, 
      page: params[:page],
      per: 10,
      methods: [:reset_password_token]
    ).all
  end
  
  def company_managers
    params[:company_managers] ||= {}
  end
  
  def remove_company_managers
    params[:company_managers] ||= {}
    if params[:company_managers].empty?
      flash[:error] = "Please select at least one company manager to remove"
    else
    end
    render :action => :company_managers
  end

  def confirm_remove_company_managers
    params[:company_manager_ids].split("|").each do |user_id,on|
      Vger::Resources::Company.save_existing(@company.id, { company_manager_ids: (@company.company_manager_ids-[user_id.to_i]) } )
    end
    flash[:notice] = "Company Managers removed successfully."
    redirect_to company_managers_company_path(@company)
  end
  
  def add_company_managers
    if request.put?
      company_managers = {}
      errors = {}
      params[:company_managers] ||= {}
      params[:company_managers].reject!{|key,data| data[:email].blank? && data[:name].blank?}
      params[:company_managers] = Hash[params[:company_managers].collect{|key,data| [data[:email], data] }]
      if params[:company_managers].empty?
        flash[:error] = "Please add at least one company manager to proceed."
        render :action => :add_company_managers and return
      end
      if params[:company_managers].find{|key,data| data[:name].blank? || data[:email].blank? }.present?
        flash[:error] = "Please enter full name as well as email id of the company managers you want to add."
        render :action => :add_company_managers and return
      end
      params[:company_managers].each do |key,user_data|
        user_data[:role] = Vger::Resources::Role::RoleName::COMPANY_MANAGER
        user_data[:notify] = user_data[:notify].present?
        company_manager = Vger::Resources::User.find_or_create(user_data)
        if !company_manager.error_messages.present?
          company_manager = Vger::Resources::User.find(company_manager.id, methods: [:company_ids])
          user_data[:id] = company_manager.id
          company_managers[company_manager.id] = user_data
          company_manager.company_ids |= [@company.id]
          company_manager.company_ids.uniq!
          company_manager = Vger::Resources::User.save_existing(company_manager.id, company_ids: company_manager.company_ids)
          if company_manager.error_messages.present?
            errors[company_manager.email] ||= []
            errors[company_manager.email] |= company_manager.error_messages
          end
        else
          errors[company_manager.email] ||= []
          errors[company_manager.email] |= company_manager.error_messages
        end
        unless errors.empty?
          flash[:error] = errors.map{|key,value| [key,value.join(",")].join(": ") }.join("<br/ >")
          render :action => :add_company_managers and return
        end
      end
      flash[:notice] = "New company managers successfully added. Instructions to login have been emailed to the company managers."
      redirect_to company_managers_company_path(@company)
    else
    end
  end

  def remove_users
    params[:users] ||= {}
    @users = Vger::Resources::User.where(:query_options => {:company_id => @company.id}, :page => params[:page], :per => 10).all
    if params[:users].empty?
      flash[:error] = "Please select at least one user to remove"
    else
    end
    render :action => :user_settings
  end

  def confirm_remove_users
    params[:user_ids].split("|").each do |user_id,on|
      Vger::Resources::User.destroy_existing(user_id)
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
        user_data[:notify] = user_data[:notify].present?
        user_data[:role] = Vger::Resources::Role::RoleName::ADMIN
        user = Vger::Resources::User.find_or_create(user_data)
        if user.error_messages.present?
          errors[user.email] ||= []
          errors[user.email] |= user.error_messages
        else
          user_data[:id] = user.id
          users[user.id] = user_data
        end
      end
      if errors.present?
        flash[:error] = "Invalid data. Please ensure that email addresses provided are in the correct format."
        render :action => :add_users and return
      else
        flash[:notice] = "New users successfully added. Instructions to login have been emailed to the users."
        redirect_to user_settings_company_path(@company)
      end
    else
    end
  end

  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:id], :include => [ :subscription ], :methods => [ :assessment_statistics, :company_manager_ids ])
  end
  
  def get_company_managers
    @company_managers = Vger::Resources::User.where(
      joins: [:companies, :roles], 
      query_options: {
        "roles.name" => Vger::Resources::Role::RoleName::COMPANY_MANAGER,
        "companies_users.company_id" => @company.id
      }, 
      page: params[:page],
      per: 10,
      methods: [:reset_password_token]
    ).all
  end
end

