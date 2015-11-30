class Suitability::CustomAssessments::UserAssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_assessment
  before_filter :get_company

  layout "tests"

  helper_method :add_users_bulk_url, 
                :competencies_url, 
                :send_reminder_to_user_url, 
                :users_url, 
                :user_url,
                :add_users_url, 
                :reports_url, 
                :send_test_to_users_path, 
                :bulk_send_test_to_users_path, 
                :new_assessment_url, 
                :expire_links_url, 
                :email_assessment_status_url, 
                :resend_invitations_url,
                :trigger_report_downloader_url,
                :export_feedback_scores_url
    
  
  def expire_links
    options = {
      :custom_assessment => {
        :args => {
          :user_id => current_user.id,
          :assessment_id => params[:id]
        }
      }
    }
    Vger::Resources::Suitability::CustomAssessment.find(params[:id])\
      .expire_links(options)
    redirect_to users_url, notice: "Links are marked for expiration."
  end

  def export_feedback_scores
    options = {
      :custom_assessment => {
        :job_klass => "Suitability::FeedbackScoresExporter",
        :args => {
          :user_id => current_user.id,
          :assessment_id => params[:id]
        }
      }
    }
    Vger::Resources::Suitability::CustomAssessment.find(params[:id])\
      .export_feedbacks_scores(options)
    redirect_to reports_url, notice: "Feedback scores will be generated and emailed to #{current_user.email}."
  end

  def email_reports
    date_range = params[:date_range].present? ? JSON.parse(params[:date_range]) : nil
    options = {
      :custom_assessment => {
        :job_klass => "Suitability::UserReportsExporter",
        :args => {
          :date_range => date_range,
          :user_id => current_user.id,
          :assessment_id => params[:id]
        }
      }
    }
    Vger::Resources::Suitability::CustomAssessment.find(params[:id])\
      .export_user_reports(options)
    redirect_to reports_url, notice: "Report summary will be generated and emailed to #{current_user.email}."
  end

  def trigger_report_downloader
    options = {
      :custom_assessment => {
        :job_klass => "Suitability::UserReportsDownloader",
        :args => {
          :email => current_user.email,
          :assessment_id => params[:id]
        }
      }
    }
    Vger::Resources::Suitability::CustomAssessment.find(params[:id])\
      .download_pdf_reports(options)
    redirect_to reports_url, notice: "Reports will be downloaded and link to download the zip file will be emailed to #{current_user.email}."
  end

  def bulk_upload
    get_s3_keys
    if !params[:bulk_upload] || !params[:bulk_upload][:file]
      flash[:error] = "Please select a csv file."
      redirect_to add_users_bulk_url and return
    end
    if !params[:candidate_stage].present?
      flash[:error] = 'Please select the purpose of assessing these Assessment Takers before proceeding!'
      redirect_to add_users_bulk_url and return
    else
      data = params[:bulk_upload][:file].read
      obj = S3Utils.upload(@s3_key, data)
      @s3_bucket = obj.bucket.name
      @functional_area_id = params[:bulk_upload][:functional_area_id]
      get_templates(params[:candidate_stage])
      if @company.subscription_mgmt
        get_packages
      end
      render :action => :send_test_to_users
    end
  end

  def get_s3_keys
    @s3_key = "suitability/users/#{@assessment.id}_#{Time.now.strftime("%d_%m_%Y_%H_%M_%S_%P")}"
  end

  # GET : renders form to add users
  # PUT : creates users and renders send_test_to_users
  def add_users
    params[:users] ||= {}
    params[:users].reject!{|key,data| data[:email].blank? && data[:name].blank?}
    #params[:users] = Hash[params[:users].collect{|key,data| [data[:email], data] }]
    # params[:candidate_stage] ||= Vger::Resources::User::Stage::EMPLOYED
    params[:upload_method] ||= "manual"
    @errors = {}
    @functional_areas = Vger::Resources::FunctionalArea.active.all.to_a
    assessment_factor_norms = @assessment.job_assessment_factor_norms.all.to_a
    functional_assessment_traits = @assessment.functional_assessment_traits.all.to_a
    add_users_allow = assessment_factor_norms.size >= 1 || functional_assessment_traits.size >= 1
    if request.put?
      if params[:candidate_stage].empty?
        flash[:error] = "Please select the purpose of assessing these Assessment Takers before proceeding!"
        render :action => :add_users and return
      else
        users = {}
        if params[:users].empty?
          flash[:error] = "Please add at least 1 Assessment Taker to send the assessment. You may also select 'Add Assessment Takers Later' to save the assessment and return to the Assessment Listings."
          render :action => :add_users and return
        end

        params[:users].each do |key,user_data|
          @errors[key] ||= []
          if @assessment.set_applicant_id && !(/^[0-9]{8}$/.match(user_data[:applicant_id]).present?)
            @errors[key] << "Applicant ID is invalid."
          end
          if user_data[:email].present?
            user = Vger::Resources::User.where(:query_options => { :email => user_data[:email] }).all[0]
          end
          user_data[:role] = Vger::Resources::Role::RoleName::CANDIDATE
          if user
            user_data[:id] = user.id
            users[user.id] = user_data
            attributes_to_update = user_data.dup
            attributes_to_update.delete(:applicant_id)
            attributes_to_update.each { |attribute,value| attributes_to_update.delete(attribute) unless user.send(attribute).blank? }
            Vger::Resources::User.save_existing(user.id, attributes_to_update)
          else
            attributes = user_data.dup
            attributes.delete(:applicant_id)
            user = Vger::Resources::User.find_or_create(attributes)
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
        get_templates(params[:candidate_stage])
        params[:send_test_to_users] = true
        params[:users] = users
        if @company.subscription_mgmt
          get_packages
        end
        render :action => :send_test_to_users
      end
    else
      if !add_users_allow
        flash[:error] = "You need to select traits before sending an assessment. Please select traits from below."
        redirect_to competencies_url
      end
    end
  end

  def add_users_bulk
  end

  # GET : renders send_reminder page
  # PUT : sends reminder and redirects to users list for current assessment
  def send_reminder
    if request.get?
      @user = Vger::Resources::User.find(params[:user_id])
      @user_assessment = Vger::Resources::Suitability::UserAssessment.where(:assessment_id => params[:id], :query_options => { :user_id => params[:user_id] }).all[0]
      get_templates(@user_assessment.candidate_stage, true)
    elsif request.put?
      @user_assessment = Vger::Resources::Suitability::UserAssessment.where(:assessment_id => params[:id], :query_options => { :user_id => params[:user_id] }).all[0]
      Vger::Resources::Suitability::UserAssessment.send_reminder(params.merge(:assessment_id => params[:id], :user_assessment_id => @user_assessment.id, :template_id => params[:template_id]))
      flash[:notice] = "Reminder was sent successfully!"
      redirect_to users_url
    end
  end

  def bulk_send_test_to_users
    params[:options] ||= {}
    Vger::Resources::Suitability::UserAssessment\
      .import_from_s3_files(:email => current_user.email,
                    :assessment_id => @assessment.id,
                    :sender_id => current_user.id,
                    :report_email_recipients => params[:report_email_recipients],
                    :send_report_to_user => params[:send_report_to_user],
                    :send_sms => params[:options][:send_sms],
                    :send_email => params[:options][:send_email],
                    :package_selection => params[:options][:package_selection],
                    :link_validity => params[:options][:link_validity],
                    :send_report_links_to_manager => params[:options][:send_report_links_to_manager].present?,
                    :send_assessment_links_to_manager => params[:options][:send_assessment_links_to_manager].present?,
                    :worksheets => [{
                      :functional_area_id => params[:functional_area_id],
                      :candidate_stage => params[:candidate_stage],
                      :template_id => params[:template_id].present? ? params[:template_id].to_i : nil,
                      :file => "BulkUpload.csv",
                      :bucket => params[:s3_bucket],
                      :key => params[:s3_key]
                    }]
                   )
    redirect_to users_url,
                notice: "Users upload in progress. User Listings will be updated and assessment will be sent to the users as they are added to the system. Notification email will be sent to #{current_user.email} on completion."
  end

  # GET : renders send_test_to_users page
  # PUT : creates user assessments for selected users and sends test to users
  def send_test_to_users
    params[:send_test_to_users] = true
    if request.put?
      params[:users] ||= {}
      params[:selected_users] ||= {}
      flash[:error] ||= ""
      user_assessments = []
      failed_user_assessments = []
      if params[:selected_users].empty?
        flash[:error] = "Please select at least one user."
        get_packages  
        render :action => :send_test_to_users and return
      end
      params[:selected_users].each do |user_id,on|
        user_assessment = @assessment.user_assessments.where(:query_options => {
          :assessment_id => @assessment.id,
          :user_id => user_id
        }).all[0]

        assessment_taker_type = Vger::Resources::Suitability::UserAssessment::AssessmentTakerType::REGULAR
        @user = Vger::Resources::User.find(user_id)
        recipients = []
        recipients |= params[:report_email_recipients].split(",") if params[:report_email_recipients].present?
        if params[:send_report_to_user]
          recipients.push @user.email
          assessment_taker_type = Vger::Resources::Suitability::UserAssessment::AssessmentTakerType::REPORT_RECEIVER
        end
        if params[:options][:send_report_links_to_manager].present? || params[:options][:send_assessment_links_to_manager].present?
          if params[:options][:manager_name].blank?
            flash[:error] = "Please enter the Notification Recipient's name<br/>".html_safe
            get_templates(params[:candidate_stage])
            get_packages
            render :action => :send_test_to_users and return
          end
          if !(Validators.email_regex =~ params[:options][:manager_email])
            flash[:error] += "Please enter a valid Email Address for Notification Recipient".html_safe
            get_templates(params[:candidate_stage])
            get_packages
            render :action => :send_test_to_users and return
          end
        end
        options = {
          :assessment_taker_type => assessment_taker_type,
          :report_link_receiver_name => params[:options][:manager_name],
          :report_link_receiver_email => params[:options][:manager_email],
          :assessment_link_receiver_name => params[:options][:manager_name],
          :assessment_link_receiver_email => params[:options][:manager_email],
          :send_report_links_to_manager => params[:options][:send_report_links_to_manager].present?,
          :send_assessment_links_to_manager => params[:options][:send_assessment_links_to_manager].present?
        }

        options.merge!(template_id: params[:template_id].to_i) if params[:template_id].present?
        options.merge!(link_expiry: params[:options][:link_validity]) if params[:options][:link_validity].present?
        options.merge!(package_selection: params[:options][:package_selection]) if params[:options][:package_selection].present?

        # create user_assessment if not present
        # add it to list of user_assessments to send email
        unless user_assessment
          user_assessment = Vger::Resources::Suitability::UserAssessment.create(
            :applicant_id => params[:users][user_id][:applicant_id],
            :assessment_id => @assessment.id,
            :user_id => user_id,
            :candidate_stage => params[:candidate_stage],
            :responses_count => 0,
            :report_email_recipients => recipients.join(","),
            :options => options,
            :language => @assessment.language
          )
          if user_assessment.error_messages.present?
            failed_user_assessments << user_assessment
          else
            user_assessments.push user_assessment
          end
        end
      end
      assessment = Vger::Resources::Suitability::CustomAssessment.send_test_to_users(
        :id => @assessment.id,
        :user_assessment_ids => user_assessments.map(&:id),
        :options => params[:options]
      ) if user_assessments.present?
      if failed_user_assessments.present?
        #flash[:error] = "Cannot send test to #{failed_user_assessments.size} users.#{failed_user_assessments.first.error_messages.join('<br/>')}"
        #redirect_to users_url
        flash[:error] = "#{failed_user_assessments.first.error_messages.join('<br/>')}"
        get_templates(params[:candidate_stage])
        get_packages
        render :action => :send_test_to_users and return
      else
        if @assessment.assessment_type == Vger::Resources::Suitability::CustomAssessment::AssessmentType::BENCHMARK
          flash[:notice] = "You have successfully sent the Benchmark!"
        else
          flash[:notice] = "Test was sent successfully!"
        end
        redirect_to users_url
      end
    else
      get_packages  
    end
  end

  # GET : renders list of users
  # checks for order_by params and sets ordering accordingly
  # checks for search params and adds query options accordingly
  # sort by status needs a custom sorting logic where sorting is decided by predefined array of statuses
  def users
    order = params[:order_by] || "default"
    order_type = params[:order_type] || "ASC"
    case order
      when "default"
        order = "suitability_user_assessments.completed_at DESC"
      when "id"
        order = "jombay_users.id #{order_type}"
      when "name"
        order = "jombay_users.name #{order_type}"
      when "status"
        column = "suitability_user_assessments.status"
        order = "case when #{column}='scored' then 1 when #{column}='started' then 2 when #{column}='sent' then 3 end, suitability_user_assessments.updated_at #{order_type}"
    end
    scope = Vger::Resources::Suitability::UserAssessment.where(:assessment_id => @assessment.id).where(:page => params[:page], :per => 10, :joins => :user, :order => order).where(:include => [:user, :user_assessment_reports])
    params[:search] ||= {}
    params[:search] = params[:search].reject{|column,value| value.blank? }
    if params[:search].present?
      scope = scope.where(:query_options => params[:search])
    end
    scope  = scope.where(:methods => [:expiry_date,:link_status])
    @user_assessments = scope
    @users = @user_assessments.map(&:user)
    @users = Kaminari.paginate_array(@users, total_count: @user_assessments.total_count).page(params[:page]).per(10)
  end

  # GET : renders user info for selected assessment
  def user
    @user = Vger::Resources::User.find(params[:user_id], :include => [ :functional_area, :industry, :location ])
    @user_assessments = Vger::Resources::Suitability::UserAssessment.where(:assessment_id => @assessment.id, :query_options => {
      :user_id => @user.id
    }, :include => [:user_assessment_reports], methods: [:link_status])
    if is_superuser?
      @custom_form = Vger::Resources::FormBuilder::FactualInformationForm.where({
        query_options: {
          :assessment_id => @assessment.id,
          :assessment_type => @assessment.class.name.gsub("Vger::Resources::","")
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

  def reports
    order = params[:order_by] || "completed_at"
    order_type = params[:order_type] || "DESC"
    case order
      when "id"
        order = "jombay_users.id #{order_type}"
      when "name"
        order = "jombay_users.name #{order_type}"
    end
    @user_assessments = Vger::Resources::Suitability::UserAssessment.where(
      :assessment_id => @assessment.id,
      :joins => [:user_assessment_reports, :user],
      :include => [:user_assessment_reports, :user],
      :query_options => {
        "suitability_user_assessment_reports.status" => Vger::Resources::Suitability::UserAssessmentReport::Status::UPLOADED
      },
      :order => order,
      :page => params[:page],
      :per=>10
    ).all
  end

  def extend_validity
    @user = Vger::Resources::User.find(params[:user_id], :include => [ :functional_area, :industry, :location ])
    @user_assessment = Vger::Resources::Suitability::UserAssessment\
      .where(:assessment_id => @assessment.id,
        :query_options => {
          :user_id => @user.id
        },
        :methods => [:expiry_date,:link_status]).first

    if request.put?
      if params[:cancel_or_update] == "Update"
        if params[:user_assessment][:validity_in_days] == ""
          # Error copy needs confirmation from product
          flash[:error] = "Please select a value for the validity of the assessment."
          redirect_to extend_validity_url()
        else
          Vger::Resources::Suitability::UserAssessment\
            .where(:assessment_id => @assessment.id, :query_options => {
              :user_id => @user.id
            }).all[0].extend_validity(params)
          redirect_to users_url()
        end
      else
        redirect_to users_url()
      end
    end
  end
  
  def expire_assessment_link
    @user_assessment = Vger::Resources::Suitability::UserAssessment.where(
      :assessment_id => params[:id],
      :query_options => {
        :user_id => params[:user_id]
      },
      :methods => [:url]
    ).all.first
    if @user_assessment
      @invitation = Vger::Resources::Invitation.find(@user_assessment.invitation_id)
      @invitation = @invitation.expire({})
      flash[:notice] = "Assessment Link expired successfully."
      redirect_to users_company_custom_assessment_path(params[:company_id],params[:id])
    else
      flash[:error] = "User Assessment not found."
      redirect_to users_company_custom_assessment_path(params[:company_id],params[:id])
    end
  end

  def send_reminder_to_pending_users
    assessment = Vger::Resources::Suitability::CustomAssessment.send_reminder_to_pending_users(
        :id =>@assessment.id)
    flash[:notice] = "Emails are queued"
    redirect_to users_url
  end

  def email_assessment_status
     options = {
      :custom_assessment => {
        :job_klass => "Suitability::Assessment::AssessmentStatusExporter",
        :args => {
          :user_id => current_user.id,
          :assessment_id => params[:id]
        }
      }
    }
    Vger::Resources::Suitability::CustomAssessment.find(params[:id])\
      .export_assessment_status(options)
    redirect_to users_url, notice: "Status Summary will be generated and emailed to #{current_user.email}."
  end

  def resend_invitations
    if request.put?
      status_params = {
        :pending => params[:assessment][:args][:pending],
        :started => params[:assessment][:args][:started]
      }
      assessment = Vger::Resources::Suitability::CustomAssessment.resend_test_to_users(
          :id => @assessment.id,
          :status => status_params,
          :send_sms => false,
          :send_email => true,
          :template_id => params[:assessment][:args][:template_id],
          :email =>params[:assessment][:args][:email]
        )
      redirect_to users_company_custom_assessment_path(@company.id, @assessment.id), notice: "Invitation Emails have been queued. Status email should arrive soon."
    else
      get_templates(nil,false)
    end
  end

  protected

  # fetches assessment if id is present in params
  # creates new assessment otherwise
  def get_assessment
    @assessment = Vger::Resources::Suitability::CustomAssessment.find(params[:id], :include => [:functional_area, :industry, :job_experience], :methods => [:competency_ids])
    if(@assessment.company_id.to_i == params[:company_id].to_i)
    else
      redirect_to root_path, alert: "Page you are looking for doesn't exist."
    end
  end


  def get_company
    methods = []
    if ["index", "users"].include?(params[:action])
      if Rails.application.config.statistics[:load_assessmentwise_statistics]
        methods << :assessmentwise_statistics
      end
    end
    @company = Vger::Resources::Company.find(params[:company_id], :methods => methods)
  end

  def get_templates(candidate_stage, reminder = false)
    category = ""
    query_options = {
    }
    if reminder
      user_assessment = Vger::Resources::Suitability::UserAssessment.where(:assessment_id => @assessment.id).all.first
      category = case user_assessment.candidate_stage
        when Vger::Resources::User::Stage::CANDIDATE
          category = Vger::Resources::Template::TemplateCategory::SEND_TEST_REMINDER_TO_CANDIDATE
        when Vger::Resources::User::Stage::EMPLOYED
          category = Vger::Resources::Template::TemplateCategory::SEND_TEST_REMINDER_TO_EMPLOYEE
        end
    else
      case candidate_stage
        when Vger::Resources::User::Stage::CANDIDATE
          category = Vger::Resources::Template::TemplateCategory::SEND_TEST_TO_CANDIDATE
        when Vger::Resources::User::Stage::EMPLOYED
          category = Vger::Resources::Template::TemplateCategory::SEND_TEST_TO_EMPLOYEE
        when nil
          category = [
                        Vger::Resources::Template::TemplateCategory::SEND_TEST_TO_CANDIDATE,
                        Vger::Resources::Template::TemplateCategory::SEND_TEST_TO_EMPLOYEE
                     ]   
                        
      end
    end
    query_options[:category] = category if category.present?
    @templates = Vger::Resources::Template\
                  .where(query_options: query_options, scopes: { global_or_for_company_id: @company.id }).all.to_a
    @templates |= Vger::Resources::Template\
                  .where(query_options: query_options, scopes: { global: nil }).all.to_a
  end

  def get_packages
    @subscriptions = Vger::Resources::Subscription.where(
      :query_options => {
        :company_id => @company.id
      },
      :order => ["valid_to ASC"],
      :scopes => { :active => nil },
      :methods => [:unlocked_invites_count]
    ).all.to_a
  end

  private

  def extend_validity_url
    extend_validity_company_custom_assessment_path(:company_id => params[:company_id],:id => params[:id],:user_id => params[:user_id])
  end
  
  def add_users_bulk_url
    add_users_bulk_company_custom_assessment_url(company_id: @company.id,id: @assessment.id)
  end

  def competencies_url
    norms_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def send_reminder_to_user_url(user,user_assessment)
    send_reminder_to_user_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id], :user_id => user.id, :user_assessment_id => user_assessment.id)
  end

  def users_url
    users_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def user_url(user)
    user_company_custom_assessment_path(params[:company_id], params[:id], :user_id => user.id)
  end

  def add_users_url
    add_users_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def reports_url
    reports_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def send_test_to_users_path
    send_test_to_users_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def bulk_send_test_to_users_path
    bulk_send_test_to_users_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id])   
  end

  def new_assessment_url
    new_company_custom_assessment_path(params[:company_id])
  end

  def expire_links_url
    expire_links_company_custom_assessment_path(params[:company_id], params[:id])
  end

  def email_assessment_status_url
    email_assessment_status_company_custom_assessment_path(params[:company_id], params[:id])
  end

  def resend_invitations_url
    resend_invitations_company_custom_assessment_path(params[:company_id], params[:id])
  end

  def trigger_report_downloader_url
    trigger_report_downloader_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def export_feedback_scores_url
    export_feedback_scores_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end
end
