class Retention::Surveys::UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_user!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_survey

  layout 'retention'
  def bulk_upload
    @s3_key = "retention/survey_users/#{@survey.id}_#{Time.now.strftime("%d_%m_%Y_%H_%M_%S_%P")}"
    if !params[:bulk_upload] || !params[:bulk_upload][:file]
      flash[:error] = "Please select a csv file."
      redirect_to add_users_bulk_company_retention_survey_url(company_id: @company.id,id: @survey.id,candidate_stage: params[:candidate_stage]) and return
    end
    data = params[:bulk_upload][:file].read
    obj = S3Utils.upload(@s3_key, data)
    @s3_bucket = obj.bucket.name
    @functional_area_id = params[:bulk_upload][:functional_area_id]
    get_templates
    render :action => :send_survey_to_users
  end

  # GET : renders form to add users
  # PUT : creates users and renders send_survey_to_users
  def add_users
    params[:users] ||= {}
    params[:users].reject!{|key,data| data[:email].blank? && data[:name].blank?}
    params[:upload_method] ||= "manual"
    @errors = {}
    if request.put?
      users = {}
      if params[:users].empty?
        flash[:error] = "Please add at least 1 User to send the survey. You may also select 'Add Users Later' to save the survey and return to the Retention Listings."
        render :action => :add_users and return
      end

      params[:users].each do |key,user_data|
        if user_data[:email].present?
          user = Vger::Resources::User.where(:query_options => { :email => user_data[:email] }).all[0]
        end
        @errors[key] ||= []
        if user
          user_data[:id] = user.id
          users[user.id] = user_data
          attributes_to_update = user_data.dup
          attributes_to_update.each { |attribute,value| attributes_to_update.delete(attribute) unless user.send(attribute).blank? }
          Vger::Resources::User.save_existing(user.id, attributes_to_update)
        else
          user = Vger::Resources::User.find_or_create(user_data)
          if user.error_messages.present?
            @errors[key] |= user.error_messages
          else
            user_data[:id] = user.id
            users[user.id] = user_data
          end
        end
      end

      unless @errors.values.flatten.empty?
        #flash[:error] = "Errors in provided data: <br/>".html_safe
        flash[:error] = @errors.map.with_index do |(user_name, user_errors), index|
          if user_errors.present?
            ["#{user_errors.join("<br/>")}"]
          end
        end.compact.uniq.join("<br/>").html_safe
        render :action => :add_users and return
      end
      get_templates
      params[:send_survey_to_users] = true
      params[:users] = users
      render :action => :send_survey_to_users
    else
      survey_traits = @survey.survey_traits.all.to_a
      if @survey.item_ids.empty?
        flash[:error] = "You need to select traits before sending an survey. Please select traits from below."
        redirect_to add_items_company_retention_survey_path(:company_id => params[:company_id], :id => params[:id])
      end
    end
  end

  def add_users_bulk

  end


  # GET : renders send_reminder page
  # PUT : sends reminder and redirects to users list for current survey
  def send_reminder
    if request.get?
      @user = Vger::Resources::User.find(params[:user_id])
      @user_survey = Vger::Resources::Retention::UserSurvey.where(:survey_id => params[:id], :query_options => { :user_id => params[:user_id] }).all[0]
    elsif request.put?
      @user_survey = Vger::Resources::Retention::UserSurvey.send_reminder(params.merge(:survey_id => params[:id], :id => params[:user_survey_id]))
      flash[:notice] = "Reminder was sent successfully!"
      redirect_to users_company_retention_survey_path(:company_id => params[:company_id], :id => params[:id])
    end
  end

  def bulk_send_survey_to_users
    Vger::Resources::Retention::UserSurvey\
      .import_from_s3_files(:email => current_user.email,
                    :survey_id => @survey.id,
                    :sender_id => current_user.id,
                    :report_email_recipients => params[:report_email_recipients],
                    :send_report_to_user => params[:send_report_to_user],
                    :send_sms => params[:send_sms],
                    :send_email => params[:send_email],
                    :worksheets => [{
                      :template_id => params[:template_id].present? ? params[:template_id].to_i : nil,
                      :file => "BulkUpload.csv",
                      :bucket => params[:s3_bucket],
                      :key => params[:s3_key]
                    }]
                   )
    redirect_to users_company_retention_survey_path(:company_id => params[:company_id], :id => params[:id]),
                notice: "Users upload in progress. User Listings will be updated and survey will be sent to the users as they are added to the system. Notification email will be sent to #{current_user.email} on completion."
  end

  # GET : renders send_survey_to_users page
  # PUT : creates user surveys for selected users and sends test to users
  def send_survey_to_users
    params[:send_survey_to_users] = true
    if request.put?
      params[:users] ||= {}
      params[:selected_users] ||= {}
      user_surveys = []
      failed_user_surveys = []
      recipient = params[:report_email_recipients]
      #if recipient.blank?
      #  flash[:error] = "Please enter valid email addresses for notification. Email addresses should be in the format 'abc@xyz.com'."
      #  render :action => :send_survey_to_users and return
      #end
      if params[:selected_users].empty?
        flash[:error] = "Please select at least one user."
        render :action => :send_survey_to_users and return
      end
      params[:selected_users].each do |user_id,on|
        user_survey = @survey.user_surveys.where(:query_options => {
          :survey_id => @survey.id,
          :user_id => user_id
        }).all[0]

        @user = Vger::Resources::User.find(user_id)
        # create user_survey if not present
        # add it to list of user_surveys to send email
        unless user_survey
          options = {}
          options.merge!(template_id: params[:template_id].to_i) if params[:template_id].present?

          user_survey = Vger::Resources::Retention::UserSurvey.create(
            :survey_id => @survey.id,
            :user_id => user_id,
            :options => options
          )

          Rails.logger.ap user_survey.error_messages

          if user_survey.error_messages.present?
            failed_user_surveys << user_survey
          else
            user_surveys.push user_survey
          end
        end
      end
      survey = Vger::Resources::Retention::Survey.send_survey_to_users(
        :id => @survey.id,
        :user_survey_ids => user_surveys.map(&:id),
        :send_sms => params[:send_sms],
        :send_email => params[:send_email]
      ) if user_surveys.present?
      if failed_user_surveys.present?
        #flash[:error] = "Cannot send test to #{failed_user_surveys.size} users.#{failed_user_surveys.first.error_messages.join('<br/>')}"
        flash[:error] = "#{failed_user_surveys.first.error_messages.join('<br/>')}"
        get_templates
        render :action => :send_survey_to_users and return
      else
        flash[:notice] = "Survey was sent successfully!"
        redirect_to users_company_retention_survey_path(@company.id, @survey.id)
      end
    end
  end

  def user
    @user = Vger::Resources::User.find(params[:user_id], :include => [ :functional_area, :industry, :location ])
    @user_surveys = Vger::Resources::Retention::UserSurvey.where(:survey_id => @survey.id, :query_options => {
      :user_id => @user.id
    })

    @reports = []#Vger::Resources::Retention::Report.where(query_options: {
      #:user_survey_id => @user_surveys.map(&:id)
    #}).all.to_a.group_by{|report| report.user_survey_id }
    if is_superuser?
      @custom_form = Vger::Resources::FormBuilder::FactualInformationForm.where({
        query_options: {
          :assessment_id => @survey.id,
          :assessment_type => @survey.class.name.gsub("Vger::Resources::","")
        }
      }).all.to_a[0]
      @factual_information = []
      if @custom_form
        @factual_information = Vger::Resources::FormBuilder::FactualInformation.where({
          query_options: {
            user_id: @user.id,
            factual_information_form_id: @custom_form.id
          },
          include: [:defined_field]
        }).all.to_a
      end
    end
  end

  # GET : renders list of users
  # checks for order_by params and sets ordering accordingly
  # checks for search params and adds query options accordingly
  # sort by status needs a exit sorting logic where sorting is decided by predefined array of statuses
  def users
    order = params[:order_by] || "default"
    order_type = params[:order_type] || "ASC"
    case order
      when "default"
        order = "retention_user_surveys.completed_at DESC"
      when "id"
        order = "users.id #{order_type}"
      when "name"
        order = "users.name #{order_type}"
      when "status"
        column = "retention_user_surveys.status"
        order = "case when #{column}='scored' then 1 when #{column}='started' then 2 when #{column}='sent' then 3 end, retention_user_surveys.updated_at #{order_type}"
    end
    scope = Vger::Resources::Retention::UserSurvey.where(:survey_id => @survey.id).where(:page => params[:page], :per => 10, :joins => :user, :order => order).where(:include => [:user])
    params[:search] ||= {}
    params[:search] = params[:search].reject{|column,value| value.blank? }
    if params[:search].present?
      scope = scope.where(:query_options => params[:search])
    end
    @user_surveys = scope
    @users = @user_surveys.map(&:user)
    @users = Kaminari.paginate_array(@users, total_count: @user_surveys.total_count).page(params[:page]).per(10)
    @reports = [] #Vger::Resources::Exit::Report.where(query_options: {
      #:user_survey_id => @user_surveys.map(&:id)
    #}).all.to_a.group_by{|report| report.user_survey_id }
  end

  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end

  def get_survey
    if params[:id].present?
      @survey = Vger::Resources::Retention::Survey.find(params[:id], company_id: @company.id)
    else
      @survey = Vger::Resources::Retention::Survey.new
    end
  end

  def get_templates
    category = Vger::Resources::Template::TemplateCategory::SEND_RETENTION_SURVEY_TO_EMPLOYEE
    @templates = Vger::Resources::Template\
                  .where(query_options: {
                    category: category
                  }, scopes: { global_or_for_company_id: @company.id }).all.to_a
    @templates |= Vger::Resources::Template\
                  .where(query_options: {
                    category: category
                  }, scopes: { global: nil }).all.to_a
  end
end
