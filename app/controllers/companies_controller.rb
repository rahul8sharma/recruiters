class CompaniesController < ApplicationController
  before_filter :authenticate_user!

  def api_resource
    Vger::Resources::Company
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  layout "companies"

  before_filter :get_company, :except => [ :index, :manage, :import_from_google_drive, :import_to_google_drive]

  def index
    @companies = Vger::Resources::Company.where(:page => params[:page], :per => 5, :methods => [ :subscription, :assessmentwise_statistics ])
  end

  def manage
  end

	def import_from_google_drive
    Vger::Resources::Company\
      .import_from_google_drive(params[:import])
    redirect_to companies_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
	end

  def export_to_google_drive
    Vger::Resources::Company\
      .export_to_google_drive(params[:export].merge(:columns => ["id","name","company_code"]))
    redirect_to companies_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def show
    if @company.hq_location_id
      @hq_location = Vger::Resources::Location.find(@company.hq_location_id, :methods => [ :address ])
    end
  end

  def candidate
  end

  def settings
  end

  def account
  end

  def company
  end

  def statistics
  end
  
  def user_settings
    params[:users] ||= {}
    @users = Vger::Resources::Admin.where(:query_options => {:company_id => @company.id}, :page => params[:page], :per => 10).all
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
    @company = Vger::Resources::Company.find(params[:id], :methods => [ :subscription, :assessment_statistics ])
  end
end

