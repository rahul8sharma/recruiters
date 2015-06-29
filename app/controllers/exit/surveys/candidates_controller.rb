class Exit::Surveys::CandidatesController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_admin!(params[:company_id]) }
  before_filter :get_company
  before_filter :get_survey

  layout 'exit'
  def bulk_upload
    s3_key = "exit/survey_candidates/#{@survey.id}_#{Time.now.strftime("%d_%m_%Y_%H_%M_%S_%P")}"
    if !params[:bulk_upload] || !params[:bulk_upload][:file]
      flash[:error] = "Please select a csv file."
      redirect_to add_candidates_bulk_company_exit_survey_url(company_id: @company.id,id: @survey.id,candidate_stage: params[:candidate_stage]) and return
    end
    data = params[:bulk_upload][:file].read
    obj = S3Utils.upload(s3_key, data)
    @s3_bucket = obj.bucket.name
    @s3_key = obj.key
    @functional_area_id = params[:bulk_upload][:functional_area_id]
    get_templates
    render :action => :send_survey_to_candidates
  end

  # GET : renders form to add candidates
  # PUT : creates candidates and renders send_survey_to_candidates
  def add_candidates
    params[:candidates] ||= {}
    params[:candidates].reject!{|key,data| data[:email].blank? && data[:name].blank?}
    params[:upload_method] ||= "manual"
    @errors = {}
    if request.put?
      candidates = {}
      if params[:candidates].empty?
        flash[:error] = "Please add at least 1 Candidate to send the survey. You may also select 'Add Candidates Later' to save the survey and return to the Exit Listings."
        render :action => :add_candidates and return
      end

      params[:candidates].each do |key,candidate_data|
        if candidate_data[:email].present?
          candidate = Vger::Resources::Candidate.where(:query_options => { :email => candidate_data[:email] }).all[0]
        end
        @errors[key] ||= []
        if candidate
          candidate_data[:id] = candidate.id
          candidates[candidate.id] = candidate_data
          attributes_to_update = candidate_data.dup
          attributes_to_update.each { |attribute,value| attributes_to_update.delete(attribute) unless candidate.send(attribute).blank? }
          Vger::Resources::Candidate.save_existing(candidate.id, attributes_to_update)
        else
          candidate = Vger::Resources::Candidate.find_or_create(candidate_data)
          if candidate.error_messages.present?
            @errors[key] |= candidate.error_messages
          else
            candidate_data[:id] = candidate.id
            candidates[candidate.id] = candidate_data
          end
        end
      end

      unless @errors.values.flatten.empty?
        #flash[:error] = "Errors in provided data: <br/>".html_safe
        flash[:error] = @errors.map.with_index do |(candidate_name, candidate_errors), index|
          if candidate_errors.present?
            ["#{candidate_errors.join("<br/>")}"]
          end
        end.compact.uniq.join("<br/>").html_safe
        render :action => :add_candidates and return
      end
      get_templates
      params[:send_survey_to_candidates] = true
      params[:candidates] = candidates
      render :action => :send_survey_to_candidates
    else
      survey_traits = @survey.survey_traits.all.to_a
      if @survey.item_ids.empty?
        flash[:error] = "You need to select traits before sending an survey. Please select traits from below."
        redirect_to add_traits_company_exit_survey_path(:company_id => params[:company_id], :id => params[:id])
      end
    end
  end

  def add_candidates_bulk

  end


  # GET : renders send_reminder page
  # PUT : sends reminder and redirects to candidates list for current survey
  def send_reminder
    if request.get?
      @candidate = Vger::Resources::Candidate.find(params[:candidate_id])
      @candidate_survey = Vger::Resources::Exit::CandidateSurvey.where(:survey_id => params[:id], :query_options => { :candidate_id => params[:candidate_id] }).all[0]
    elsif request.put?
      @candidate_survey = Vger::Resources::Exit::CandidateSurvey.send_reminder(params.merge(:survey_id => params[:id], :id => params[:candidate_survey_id]))
      flash[:notice] = "Reminder was sent successfully!"
      redirect_to candidates_company_exit_survey_path(:company_id => params[:company_id], :id => params[:id])
    end
  end

  def bulk_send_survey_to_candidates
    Vger::Resources::Exit::CandidateSurvey\
      .import_from_s3_files(:email => current_user.email,
                    :survey_id => @survey.id,
                    :sender_type => current_user.type,
                    :sender_name => current_user.name,
                    :report_email_recipients => params[:report_email_recipients],
                    :send_report_to_candidate => params[:send_report_to_candidate],
                    :send_sms => params[:send_sms],
                    :send_email => params[:send_email],
                    :worksheets => [{
                      :template_id => params[:template_id].present? ? params[:template_id].to_i : nil,
                      :file => "BulkUpload.csv",
                      :bucket => params[:s3_bucket],
                      :key => params[:s3_key]
                    }]
                   )
    redirect_to candidates_company_exit_survey_path(:company_id => params[:company_id], :id => params[:id]),
                notice: "Candidates upload in progress. Candidate Listings will be updated and survey will be sent to the candidates as they are added to the system. Notification email will be sent to #{current_user.email} on completion."
  end

  # GET : renders send_survey_to_candidates page
  # PUT : creates candidate surveys for selected candidates and sends test to candidates
  def send_survey_to_candidates
    params[:send_survey_to_candidates] = true
    if request.put?
      params[:candidates] ||= {}
      params[:selected_candidates] ||= {}
      candidate_surveys = []
      failed_candidate_surveys = []
      recipient = params[:report_email_recipients]
      #if recipient.blank?
      #  flash[:error] = "Please enter valid email addresses for notification. Email addresses should be in the format 'abc@xyz.com'."
      #  render :action => :send_survey_to_candidates and return
      #end
      if params[:selected_candidates].empty?
        flash[:error] = "Please select at least one candidate."
        render :action => :send_survey_to_candidates and return
      end
      params[:selected_candidates].each do |candidate_id,on|
        candidate_survey = @survey.candidate_surveys.where(:query_options => {
          :survey_id => @survey.id,
          :candidate_id => candidate_id
        }).all[0]

        @candidate = Vger::Resources::Candidate.find(candidate_id)
        # create candidate_survey if not present
        # add it to list of candidate_surveys to send email
        unless candidate_survey
          options = {}
          options.merge!(template_id: params[:template_id].to_i) if params[:template_id].present?

          candidate_survey = Vger::Resources::Exit::CandidateSurvey.create(
            :survey_id => @survey.id,
            :candidate_id => candidate_id,
            :options => options
          )

          Rails.logger.ap candidate_survey.error_messages

          if candidate_survey.error_messages.present?
            failed_candidate_surveys << candidate_survey
          else
            candidate_surveys.push candidate_survey
          end
        end
      end
      survey = Vger::Resources::Exit::Survey.send_survey_to_candidates(
        :id => @survey.id,
        :candidate_survey_ids => candidate_surveys.map(&:id),
        :send_sms => params[:send_sms],
        :send_email => params[:send_email]
      ) if candidate_surveys.present?
      if failed_candidate_surveys.present?
        #flash[:error] = "Cannot send test to #{failed_candidate_surveys.size} candidates.#{failed_candidate_surveys.first.error_messages.join('<br/>')}"
        flash[:error] = "#{failed_candidate_surveys.first.error_messages.join('<br/>')}"
        get_templates
        render :action => :send_survey_to_candidates and return
      else
        flash[:notice] = "Survey was sent successfully!"
        redirect_to candidates_company_exit_survey_path(@company.id, @survey.id)
      end
    end
  end

  def candidate
    @candidate = Vger::Resources::Candidate.find(params[:candidate_id], :include => [ :functional_area, :industry, :location ])
    @candidate_surveys = Vger::Resources::Exit::CandidateSurvey.where(:survey_id => @survey.id, :query_options => {
      :candidate_id => @candidate.id
    })
    @reports = Vger::Resources::Exit::Report.where(query_options: {
      :candidate_survey_id => @candidate_surveys.map(&:id)
    }).all.to_a.group_by{|report| report.candidate_survey_id }
    if is_superadmin?
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
            candidate_id: @candidate.id,
            factual_information_form_id: @custom_form.id
          },
          include: [:defined_field]
        }).all.to_a
      end
    end
  end

  # GET : renders list of candidates
  # checks for order_by params and sets ordering accordingly
  # checks for search params and adds query options accordingly
  # sort by status needs a exit sorting logic where sorting is decided by predefined array of statuses
  def candidates
    order = params[:order_by] || "default"
    order_type = params[:order_type] || "ASC"
    case order
      when "default"
        order = "exit_candidate_surveys.completed_at DESC"
      when "id"
        order = "candidates.id #{order_type}"
      when "name"
        order = "candidates.name #{order_type}"
      when "status"
        column = "exit_candidate_surveys.status"
        order = "case when #{column}='scored' then 1 when #{column}='started' then 2 when #{column}='sent' then 3 end, exit_candidate_surveys.updated_at #{order_type}"
    end
    scope = Vger::Resources::Exit::CandidateSurvey.where(:survey_id => @survey.id).where(:page => params[:page], :per => 10, :joins => :candidate, :order => order).where(:include => [:candidate])
    params[:search] ||= {}
    params[:search] = params[:search].reject{|column,value| value.blank? }
    if params[:search].present?
      scope = scope.where(:query_options => params[:search])
    end
    @candidate_surveys = scope
    @candidates = @candidate_surveys.map(&:candidate)
    @candidates = Kaminari.paginate_array(@candidates, total_count: @candidate_surveys.total_count).page(params[:page]).per(10)
    @reports = Vger::Resources::Exit::Report.where(query_options: {
      :candidate_survey_id => @candidate_surveys.map(&:id)
    }).all.to_a.group_by{|report| report.candidate_survey_id }
  end

  protected

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end

  def get_survey
    if params[:id].present?
      @survey = Vger::Resources::Exit::Survey.find(params[:id], company_id: @company.id)
    else
      @survey = Vger::Resources::Exit::Survey.new
    end
  end

  def get_templates
    category = Vger::Resources::Template::TemplateCategory::SEND_EXIT_SURVEY_TO_EMPLOYEE
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
