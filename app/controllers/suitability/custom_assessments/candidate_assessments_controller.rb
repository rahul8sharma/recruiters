class Suitability::CustomAssessments::CandidateAssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_assessment
  before_filter :get_company

  layout "tests"

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
    options = {
      :custom_assessment => {
        :job_klass => "Suitability::CandidateReportsExporter",
        :args => {
          :user_id => current_user.id,
          :assessment_id => params[:id]
        }
      }
    }
    Vger::Resources::Suitability::CustomAssessment.find(params[:id])\
      .export_candidate_reports(options)
    redirect_to reports_url, notice: "Report summary will be generated and emailed to #{current_user.email}."
  end



  def bulk_upload
    @s3_key = "suitability/candidates/#{@assessment.id}_#{Time.now.strftime("%d_%m_%Y_%H_%M_%S_%P")}"

    if !params[:bulk_upload] || !params[:bulk_upload][:file]
      flash[:error] = "Please select a csv file."
      redirect_to add_candidates_bulk_company_custom_assessment_url(company_id: @company.id,id: @assessment.id,candidate_stage: params[:candidate_stage]) and return
    end
    if !params[:candidate_stage].present?
      flash[:error] = 'Please select the purpose of assessing these Assessment Takers before proceeding!'
      redirect_to add_candidates_bulk_company_custom_assessment_url(company_id: @company.id,id: @assessment.id) and return
    else
      data = params[:bulk_upload][:file].read
      obj = S3Utils.upload(@s3_key, data)
      @s3_bucket = obj.bucket.name
      @functional_area_id = params[:bulk_upload][:functional_area_id]
      get_templates(params[:candidate_stage])
      if @company.subscription_mgmt
        get_packages
      end
      render :action => :send_test_to_candidates
    end
  end

  # GET : renders form to add candidates
  # PUT : creates candidates and renders send_test_to_candidates
  def add_candidates
    params[:candidates] ||= {}
    params[:candidates].reject!{|key,data| data[:email].blank? && data[:name].blank?}
    #params[:candidates] = Hash[params[:candidates].collect{|key,data| [data[:email], data] }]
    # params[:candidate_stage] ||= Vger::Resources::Candidate::Stage::EMPLOYED
    params[:upload_method] ||= "manual"
    @errors = {}
    @functional_areas = Vger::Resources::FunctionalArea.active.all.to_a
    assessment_factor_norms = @assessment.job_assessment_factor_norms.all.to_a
    functional_assessment_traits = @assessment.functional_assessment_traits.all.to_a
    add_candidates_allow = assessment_factor_norms.size > 1 || functional_assessment_traits.size >= 1
    if request.put?
      if params[:candidate_stage].empty?
        flash[:error] = "Please select the purpose of assessing these Assessment Takers before proceeding!"
        render :action => :add_candidates and return
      else
        candidates = {}
        if params[:candidates].empty?
          flash[:error] = "Please add at least 1 Assessment Taker to send the assessment. You may also select 'Add Assessment Takers Later' to save the assessment and return to the Assessment Listings."
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
            attributes_to_update.delete(:applicant_id)
            attributes_to_update.each { |attribute,value| attributes_to_update.delete(attribute) unless candidate.send(attribute).blank? }
            Vger::Resources::Candidate.save_existing(candidate.id, attributes_to_update)
          else
            attributes = candidate_data.dup
            attributes.delete(:applicant_id)
            candidate = Vger::Resources::Candidate.create(attributes)
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
        get_templates(params[:candidate_stage])
        params[:send_test_to_candidates] = true
        params[:candidates] = candidates
        if @company.subscription_mgmt
          get_packages
        end
        render :action => :send_test_to_candidates
      end
    else
      if !add_candidates_allow
        flash[:error] = "You need to select traits before sending an assessment. Please select traits from below."
        redirect_to norms_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id])
      end
    end
  end

  def add_candidates_bulk
  end

  # GET : renders send_reminder page
  # PUT : sends reminder and redirects to candidates list for current assessment
  def send_reminder
    if request.get?
      @candidate = Vger::Resources::Candidate.find(params[:candidate_id])
      @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.where(:assessment_id => params[:id], :query_options => { :candidate_id => params[:candidate_id] }).all[0]
      get_templates(@candidate_assessment.candidate_stage, true)
    elsif request.put?
      @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.where(:assessment_id => params[:id], :query_options => { :candidate_id => params[:candidate_id] }).all[0]
      Vger::Resources::Suitability::CandidateAssessment.send_reminder(params.merge(:assessment_id => params[:id], :candidate_assessment_id => @candidate_assessment.id, :template_id => params[:template_id]))
      flash[:notice] = "Reminder was sent successfully!"
      redirect_to candidates_url
    end
  end

  def bulk_send_test_to_candidates
    params[:options] ||= {}
    Vger::Resources::Suitability::CandidateAssessment\
      .import_from_s3_files(:email => current_user.email,
                    :assessment_id => @assessment.id,
                    :sender_type => current_user.type,
                    :sender_name => current_user.name,
                    :report_email_recipients => params[:report_email_recipients],
                    :send_report_to_candidate => params[:send_report_to_candidate],
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
    redirect_to candidates_url,
                notice: "Candidates upload in progress. Candidate Listings will be updated and assessment will be sent to the candidates as they are added to the system. Notification email will be sent to #{current_user.email} on completion."
  end

  # GET : renders send_test_to_candidates page
  # PUT : creates candidate assessments for selected candidates and sends test to candidates
  def send_test_to_candidates
    params[:send_test_to_candidates] = true
    if request.put?
      params[:candidates] ||= {}
      params[:selected_candidates] ||= {}
      flash[:error] ||= ""
      candidate_assessments = []
      failed_candidate_assessments = []
      if params[:selected_candidates].empty?
        flash[:error] = "Please select at least one candidate."
        get_packages  
        render :action => :send_test_to_candidates and return
      end
      params[:selected_candidates].each do |candidate_id,on|
        candidate_assessment = @assessment.candidate_assessments.where(:query_options => {
          :assessment_id => @assessment.id,
          :candidate_id => candidate_id
        }).all[0]

        assessment_taker_type = Vger::Resources::Suitability::CandidateAssessment::AssessmentTakerType::REGULAR
        @candidate = Vger::Resources::Candidate.find(candidate_id)
        recipients = []
        recipients |= params[:report_email_recipients].split(",") if params[:report_email_recipients].present?
        if params[:send_report_to_candidate]
          recipients.push @candidate.email
          assessment_taker_type = Vger::Resources::Suitability::CandidateAssessment::AssessmentTakerType::REPORT_RECEIVER
        end
        if params[:options][:send_report_links_to_manager].present? || params[:options][:send_assessment_links_to_manager].present?
          if params[:options][:manager_name].blank?
            flash[:error] = "Please enter the Notification Recipient's name<br/>".html_safe
            get_templates(params[:candidate_stage])
            get_packages
            render :action => :send_test_to_candidates and return
          end
          if !(Validators.email_regex =~ params[:options][:manager_email])
            flash[:error] += "Please enter a valid Email Address for Notification Recipient".html_safe
            get_templates(params[:candidate_stage])
            get_packages
            render :action => :send_test_to_candidates and return
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

        # create candidate_assessment if not present
        # add it to list of candidate_assessments to send email
        unless candidate_assessment
          candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.create(
            :applicant_id => params[:candidates][candidate_id][:applicant_id],
            :assessment_id => @assessment.id,
            :candidate_id => candidate_id,
            :candidate_stage => params[:candidate_stage],
            :responses_count => 0,
            :report_email_recipients => recipients.join(","),
            :options => options,
            :language => @assessment.language
          )
          if candidate_assessment.error_messages.present?
            failed_candidate_assessments << candidate_assessment
          else
            candidate_assessments.push candidate_assessment
          end
        end
      end
      assessment = Vger::Resources::Suitability::CustomAssessment.send_test_to_candidates(
        :id => @assessment.id,
        :candidate_assessment_ids => candidate_assessments.map(&:id),
        :options => params[:options]
      ) if candidate_assessments.present?
      if failed_candidate_assessments.present?
        #flash[:error] = "Cannot send test to #{failed_candidate_assessments.size} candidates.#{failed_candidate_assessments.first.error_messages.join('<br/>')}"
        #redirect_to candidates_url
        flash[:error] = "#{failed_candidate_assessments.first.error_messages.join('<br/>')}"
        get_templates(params[:candidate_stage])
        get_packages
        render :action => :send_test_to_candidates and return
      else
        if @assessment.assessment_type == Vger::Resources::Suitability::CustomAssessment::AssessmentType::BENCHMARK
          flash[:notice] = "You have successfully sent the Benchmark!"
        else
          flash[:notice] = "Test was sent successfully!"
        end
        redirect_to candidates_url
      end
    else
      get_packages  
    end
  end

  # GET : renders list of candidates
  # checks for order_by params and sets ordering accordingly
  # checks for search params and adds query options accordingly
  # sort by status needs a custom sorting logic where sorting is decided by predefined array of statuses
  def candidates
    order = params[:order_by] || "default"
    order_type = params[:order_type] || "ASC"
    case order
      when "default"
        order = "suitability_candidate_assessments.completed_at DESC"
      when "id"
        order = "candidates.id #{order_type}"
      when "name"
        order = "candidates.name #{order_type}"
      when "status"
        column = "suitability_candidate_assessments.status"
        order = "case when #{column}='scored' then 1 when #{column}='started' then 2 when #{column}='sent' then 3 end, suitability_candidate_assessments.updated_at #{order_type}"
    end
    scope = Vger::Resources::Suitability::CandidateAssessment.where(:assessment_id => @assessment.id).where(:page => params[:page], :per => 10, :joins => :candidate, :order => order).where(:include => [:candidate, :candidate_assessment_reports])
    params[:search] ||= {}
    params[:search] = params[:search].reject{|column,value| value.blank? }
    if params[:search].present?
      scope = scope.where(:query_options => params[:search])
    end
    scope  = scope.where(:methods => [:expiry_date,:link_status])
    @candidate_assessments = scope
    @candidates = @candidate_assessments.map(&:candidate)
    @candidates = Kaminari.paginate_array(@candidates, total_count: @candidate_assessments.total_count).page(params[:page]).per(10)
  end

  def reports
    order = params[:order_by] || "completed_at"
    order_type = params[:order_type] || "DESC"
    case order
      when "id"
        order = "candidates.id #{order_type}"
      when "name"
        order = "candidates.name #{order_type}"
    end
    @candidate_assessments = Vger::Resources::Suitability::CandidateAssessment.where(
      :assessment_id => @assessment.id,
      :joins => [:candidate_assessment_reports, :candidate],
      :include => [:candidate_assessment_reports, :candidate],
      :query_options => {
        "suitability_candidate_assessment_reports.status" => Vger::Resources::Suitability::CandidateAssessmentReport::Status::UPLOADED
      },
      :order => order,
      :page => params[:page],
      :per=>10
    ).all
  end

  # GET : renders candidate info for selected assessment
  def candidate
    @candidate = Vger::Resources::Candidate.find(params[:candidate_id], :include => [ :functional_area, :industry, :location ])
    @candidate_assessments = Vger::Resources::Suitability::CandidateAssessment.where(:assessment_id => @assessment.id, :query_options => {
      :candidate_id => @candidate.id
    }, :include => [:candidate_assessment_reports])
    if is_superadmin?
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
            candidate_id: @candidate.id,
            factual_information_form_id: @custom_form.id
          },
          include: [:defined_field]
        }).all.to_a
      end
    end
  end

  def extend_validity
    @candidate = Vger::Resources::Candidate.find(params[:candidate_id], :include => [ :functional_area, :industry, :location ])
    @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment\
      .where(:assessment_id => @assessment.id,
        :query_options => {
          :candidate_id => @candidate.id
        },
        :methods => [:expiry_date,:link_status]).first

    if request.put?
      if params[:cancel_or_update] == "Update"
        if params[:candidate_assessment][:validity_in_days] == ""
          # Error copy needs confirmation from product
          flash[:error] = "Please select a value for the validity of the assessment."
          redirect_to extend_validity_company_custom_assessment_path(:company_id => params[:company_id],:id => params[:id],:candidate_id => params[:candidate_id])
        else
          Vger::Resources::Suitability::CandidateAssessment\
            .where(:assessment_id => @assessment.id, :query_options => {
              :candidate_id => @candidate.id
            }).all[0].extend_validity(params)
          redirect_to candidates_url()
        end
      else
        redirect_to candidates_url()
      end
    end
  end
  
  def expire_assessment_link
    @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.where(
      :assessment_id => params[:id],
      :query_options => {
        :candidate_id => params[:candidate_id]
      },
      :methods => [:url]
    ).all.first
    if @candidate_assessment
      @invitation = Vger::Resources::Invitation.save_existing(@candidate_assessment.invitation_id, :status => Vger::Resources::Invitation::Status::EXPIRED)
      if @invitation.error_messages.present?
        flash[:error] = @invitation.error_messages.join("<br/>").html_safe
        redirect_to candidates_company_custom_assessment_path(params[:company_id],params[:id])
      else
        flash[:notice] = "Assessment Link expired successfully."
        redirect_to candidates_company_custom_assessment_path(params[:company_id],params[:id])
      end
    else
      flash[:error] = "Candidate Assessment not found."
      redirect_to candidates_company_custom_assessment_path(params[:company_id],params[:id])
    end
  end

  def send_reminder_to_pending_candidates
    assessment = Vger::Resources::Suitability::CustomAssessment.send_reminder_to_pending_candidates(
        :id =>@assessment.id)
    flash[:notice] = "Emails are queued"
    redirect_to candidates_url
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
    redirect_to candidates_url, notice: "Status Summary will be generated and emailed to #{current_user.email}."
  end

  def send_reminder_to_candidate_url
    send_reminder_to_candidate_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id], :candidate_id => params[:candidate_id], :candidate_assessment_id => @candidate_assessment.id)
  end

  def resend_invitations
    if request.put?
      status_params = {
        :pending => params[:assessment][:args][:pending],
        :started => params[:assessment][:args][:started]
      }
      assessment = Vger::Resources::Suitability::CustomAssessment.resend_test_to_candidates(
          :id => @assessment.id,
          :status => status_params,
          :send_sms => false,
          :send_email => true,
          :template_id => params[:assessment][:args][:template_id],
          :email =>params[:assessment][:args][:email]
        )
      redirect_to candidates_company_custom_assessment_path(@company.id, @assessment.id), notice: "Invitation Emails have been queued. Status email should arrive soon."
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
    if ["index", "candidates"].include?(params[:action])
      if Rails.application.config.statistics[:load_assessmentwise_statistics]
        methods << :assessmentwise_statistics
      end
    end
    @company = Vger::Resources::Company.find(params[:company_id], :methods => methods)
  end

  def candidates_url
    candidates_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def add_candidates_url
    add_candidates_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def reports_url
    reports_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id])
  end

  def get_templates(candidate_stage, reminder = false)
    category = ""
    query_options = {
      company_id: @company.id
    }
    if reminder
      candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.where(:assessment_id => @assessment.id).all.first
      category = case candidate_assessment.candidate_stage
        when Vger::Resources::Candidate::Stage::CANDIDATE
          category = Vger::Resources::Template::TemplateCategory::SEND_TEST_REMINDER_TO_CANDIDATE
        when Vger::Resources::Candidate::Stage::EMPLOYED
          category = Vger::Resources::Template::TemplateCategory::SEND_TEST_REMINDER_TO_EMPLOYEE
        end
    else
      case candidate_stage
        when Vger::Resources::Candidate::Stage::CANDIDATE
          category = Vger::Resources::Template::TemplateCategory::SEND_TEST_TO_CANDIDATE
        when Vger::Resources::Candidate::Stage::EMPLOYED
          category = Vger::Resources::Template::TemplateCategory::SEND_TEST_TO_EMPLOYEE
      end
    end
    query_options[:category] = category if category.present?
    @templates = Vger::Resources::Template\
                  .where(query_options: query_options).all.to_a
    query_options[:company_id] = nil
    @templates |= Vger::Resources::Template\
                  .where(query_options: query_options).all.to_a
  end

  def get_packages
    @subscriptions = Vger::Resources::Subscription.where(
      :query_options => {
        :company_id => @company.id
      },
      :order => ["valid_to ASC"],
      :scopes => { :active => nil },
      :methods => [:assessments_sent]
    ).all.to_a
  end
end
