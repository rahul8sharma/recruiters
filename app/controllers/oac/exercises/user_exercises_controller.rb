class Oac::Exercises::UserExercisesController < ApplicationController
  include TemplatesHelper
  before_filter :authenticate_user!
  before_filter { authorize_user!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_exercise
  before_filter :validate_exercise
  before_filter :get_exercise_tools, only: [:download_bulk_upload_csv]
  layout 'oac/oac'
  
  def download_bulk_upload_csv
    path = "vac_bulk_upload_sample"
    file = Vger::Jombay::Workbook.open(path,"w") do |csv|
      header = ["name","email","phone"]
      custom_columns = []
      @exercise_tools.each do |exercise_tool|
        tool = exercise_tool.tool
        tool.integration_configuration["link_configuration"] ||= {}
        tool.integration_configuration["link_configuration"].each do |index, config|
          custom_columns << "#{tool.name}_#{config['name']}".underscore
        end
      end
      header |= custom_columns.compact.uniq
      csv << header
    end  
    send_file(file.path)
  end

  def export_report_summary
    Vger::Resources::User.get(
      "/sidekiq/queue-job?job_klass=Oac::UserReportsExporter&"+
      "args[exercise_id]=#{params[:id]}&"+
      "args[user_id]=#{current_user.id}"
    )
    redirect_to request.env['HTTP_REFERER'], notice: "Report summary will be generated and emailed to #{current_user.email}."
  end
  
  def candidates
    order = params[:order_by] || "status"
    order_type = params[:order_type] || "DESC"
    case order
      when "default"
        order = "oac_user_exercises.updated_at DESC"
      when "id"
        order = "oac_user_exercises.id #{order_type}"
      when "status"
        column = "oac_user_exercises.status"
        order = "case when #{column}='scored' then 3 when #{column}='completed' then 2 when #{column}='pending' then 1 end, oac_user_exercises.status DESC, oac_user_exercises.id #{order_type}"
    end
    @user_exercises = Vger::Resources::Oac::UserExercise.where(
      :exercise_id => @exercise.id,
      query_options: {
        :exercise_id => @exercise.id
      },
      include: [:user, :user_exercise_reports],
      page: params[:page],
      per: 10,
      order: order
    ).all
  end

  def candidate
    @user = Vger::Resources::User.find(params[:user_id])
  end

  def add_candidates
    params[:users] ||= {}
    params[:users].reject!{|key,data| data[:email].blank? && data[:name].blank?}
    @errors = {}
    if request.put?
      if params[:candidate_stage].empty?
        flash[:error] = "Please select the purpose of assessing these Assessment Takers before proceeding!"
        render :action => :add_candidates and return
      else
        users = {}
        if params[:users].empty?
          flash[:error] = "Please add at least 1 Assessment Taker to send the exercise. You may also select 'Add Assessment Takers Later' to save the exercise and return to the Assessment Listings."
          render :action => :add_candidates and return
        end

        params[:users].each do |key,user_data|
          @errors[key] ||= []
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
          render :action => :add_candidates and return
        end
        get_templates(params[:candidate_stage])
        params[:send_test_to_users] = true
        params[:users] = users
        render :action => :send_assessment
      end
    end
  end

  def add_users_bulk
  end
  
  def bulk_upload
    get_s3_keys
    if !params[:bulk_upload] || !params[:bulk_upload][:file]
      flash[:error] = "Please select a xls file."
      redirect_to add_candidates_company_oac_exercise_path(@company.id, @exercise.id) and return
    end
    data = params[:bulk_upload][:file].read
    obj = S3Utils.upload(@s3_key, data)
    @s3_bucket = obj.bucket.name
    get_templates(Vger::Resources::User::Stage::EMPLOYED, false)
    render :action => :send_assessment
  end
  
  def bulk_send_assessment
    params[:options] ||= {}
    Vger::Resources::Oac::UserExercise\
      .import_from_s3_files(:email => current_user.email,
                    :exercise_id => @exercise.id,
                    :sender_id => current_user.id,
                    :report_email_recipients => params[:report_email_recipients],
                    :send_report_to_user => params[:send_report_to_user],
                    :send_sms => params[:options][:send_sms],
                    :send_email => params[:options][:send_email],
                    :worksheets => [{
                      :candidate_stage => Vger::Resources::User::Stage::EMPLOYED,
                      :template_id => params[:template_id].present? ? params[:template_id].to_i : nil,
                      :file => "BulkUpload.xls",
                      :bucket => params[:s3_bucket],
                      :key => params[:s3_key]
                    }]
                   )
    redirect_to candidates_company_oac_exercise_path(@company.id,@exercise.id),
                notice: "Users upload in progress. User Listings will be updated and assessment will be sent to the users as they are added to the system. Notification email will be sent to #{current_user.email} on completion."
  end

  def assign_assessors
  end
  
  def send_assessment
    params[:send_test_to_users] = true
    if request.put?
      params[:users] ||= {}
      params[:selected_users] ||= {}
      flash[:error] ||= ""
      user_exercises = []
      failed_user_exercises = []
      if params[:selected_users].empty?
        flash[:error] = "Please select at least one user."
        get_templates(params[:candidate_stage])
        render :action => :send_assessment and return
      end
      params[:selected_users].each do |user_id,on|
        user_exercise = @exercise.user_exercises.where(
          :exercise_id => @exercise.id,
          :query_options => {
            :exercise_id => @exercise.id,
            :user_id => user_id
          }
        ).all[0]

        exercise_taker_type = Vger::Resources::Suitability::UserAssessment::AssessmentTakerType::REGULAR
        @user = Vger::Resources::User.find(user_id)
        recipients = []
        options = {
          :candidate_stage => params[:candidate_stage],
          :exercise_taker_type => exercise_taker_type
        }

        options.merge!(template_id: params[:template_id].to_i) if params[:template_id].present?
        # create user_exercise if not present
        # add it to list of user_exercises to send email
        unless user_exercise
          user_exercise = Vger::Resources::Oac::UserExercise.create(
            :exercise_id => @exercise.id,
            :user_id => user_id,
            :options => options
          )
          if user_exercise.error_messages.present?
            failed_user_exercises << user_exercise
          else
            user_exercises.push user_exercise
          end
        end
      end
      exercise = Vger::Resources::Oac::Exercise.send_test_to_users(
        :id => @exercise.id,
        :user_exercise_ids => user_exercises.map(&:id),
        :options => {
          :send_email => true,
          :template_id => params[:template_id]
        }
      ) if user_exercises.present?
      if failed_user_exercises.present?
        flash[:error] = "#{failed_user_exercises.first.error_messages.join('<br/>')}"
        get_templates(params[:candidate_stage])
        render :action => :send_assessment and return
      else
        flash[:notice] = "Test was sent successfully!"
        redirect_to candidates_company_oac_exercise_path(@company.id, @exercise.id)
      end
    end
  end
  
  def send_reminder
    if request.get?
      @user = Vger::Resources::User.find(params[:user_id])
      @user_assessment = Vger::Resources::Oac::UserExercise.where(
        :exercise_id => params[:id], 
        :query_options => { 
          :exercise_id => params[:id], 
          :user_id => params[:user_id] 
        }
      ).all[0]
      get_templates(Vger::Resources::User::Stage::EMPLOYED, true)
    elsif request.put?
      @user_exercises = Vger::Resources::Oac::UserExercise.where(
        :exercise_id => params[:id], 
        :query_options => { 
        :exercise_id => params[:id], 
          :user_id => params[:user_id] 
        }
      ).all.to_a
      Vger::Resources::Oac::Exercise.send_reminder_to_users(
        params.merge(
          :exercise_id => params[:id], 
          :user_exercise_ids => @user_exercises.map(&:id), 
          :template_id => params[:template_id]
        )
      )
      flash[:notice] = "Reminder was sent successfully!"
      redirect_to candidates_company_oac_exercise_path(@company.id, @exercise.id)
    end
  end
  
  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end
  
  def get_exercise
    @exercise = Vger::Resources::Oac::Exercise.find(params[:id])
  end
  
  def get_templates(candidate_stage, reminder = false)
    category = ""
    if reminder
      category = Vger::Resources::Template::TemplateCategory::SEND_OAC_REMINDER_TO_EMPLOYEE
    else
      category = Vger::Resources::Template::TemplateCategory::SEND_OAC_TO_EMPLOYEE
    end
    query_options = {
      "template_categories.name" => category 
    }
    @templates = get_templates_for_company(query_options, @company.id)
    @templates |= get_global_templates(query_options)
  end
  
  def validate_exercise
    if @exercise.workflow_status != Vger::Resources::Oac::Exercise::WorkflowStatus::READY
      redirect_to home_company_oac_exercises_path(@company.id)
    end
  end
  
  def get_s3_keys
    @s3_key = "oac/#{@exercise.id}/user_exercises/#{Time.now.strftime("%d_%m_%Y_%H_%M_%S_%P")}"
  end
  
  def get_exercise_tools
    @exercise_tools = Vger::Resources::Oac::ExerciseTool.where(
      exercise_id: @exercise.id, 
      query_options: {
        exercise_id: @exercise.id
      },
      include: [:tool]
    ).all
  end
end
