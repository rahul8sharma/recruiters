class Suitability::CustomAssessments::CandidateAssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_assessment
  before_filter :get_company
  
  layout "tests"
  
  def email_reports
    options = {
      :custom_assessment => {
        :job_klass => "CandidateReportsExporter",
        :args => {
          :user_id => current_user.id,
          :assessment_id => params[:id]
        }
      }
    }
    Vger::Resources::Suitability::CustomAssessment.find(params[:id])\
      .export_candidate_reports(options)
    redirect_to candidates_url, notice: "Report summary will be generated and emailed to #{current_user.email}."
  end

  def bulk_upload
    s3_bucket_name = "bulk_upload_candidates_#{Rails.env.to_s}"
    s3_key = "candidates_#{@assessment.id}_#{Time.now.strftime("%d_%m_%Y_%H_%M_%S_%P")}"
    unless params[:bulk_upload][:file]
      flash[:error] = "Please select a csv file."
      redirect_to add_candidates_url and return
    end
    data = params[:bulk_upload][:file].read
    S3Utils.upload(s3_bucket_name, s3_key, data)
    @s3_bucket = s3_bucket_name
    @s3_key = s3_key
    @functional_area_id = params[:bulk_upload][:functional_area_id]
    render :action => :send_test_to_candidates
  end
  
  # GET : renders form to add candidates
  # PUT : creates candidates and renders send_test_to_candidates
  def add_candidates
    params[:candidates] ||= {}
    params[:candidates].reject!{|key,data| data[:email].blank? && data[:name].blank?}
    #params[:candidates] = Hash[params[:candidates].collect{|key,data| [data[:email], data] }]
    params[:candidate_stage] ||= Vger::Resources::Candidate::Stage::EMPLOYED
    params[:upload_method] ||= "manual"
    @functional_areas = Vger::Resources::FunctionalArea.active.all.to_a
    @errors = {}
    assessment_factor_norms = @assessment.job_assessment_factor_norms.all.to_a
    if request.put?
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
          attributes_to_update.each { |attribute,value| attributes_to_update.delete(attribute) unless candidate.send(attribute).blank? }
          Vger::Resources::Candidate.save_existing(candidate.id, attributes_to_update)
        else
          candidate = Vger::Resources::Candidate.create(candidate_data)
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
      params[:candidates] = candidates
      render :action => :send_test_to_candidates
    else
      if assessment_factor_norms.size <= 1
        flash[:error] = "You need to select traits before sending an assessment. Please select traits from below."
        redirect_to norms_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id])
      end
    end
  end
  
  # GET : renders send_reminder page
  # PUT : sends reminder and redirects to candidates list for current assessment
  def send_reminder
    if request.get?
      @candidate = Vger::Resources::Candidate.find(params[:candidate_id])
      @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.where(:assessment_id => params[:id], :query_options => { :candidate_id => params[:candidate_id] }).all[0]
    elsif request.put?
      @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.send_reminder(params.merge(:assessment_id => params[:id], :id => params[:candidate_assessment_id]))
      flash[:notice] = "Reminder was sent successfully!"
      redirect_to candidates_url
    end  
  end
  
  def bulk_send_test_to_candidates
    Vger::Resources::Candidate\
      .import_from_s3_files(:email => current_user.email,
                    :assessment_id => @assessment.id,
                    :sender_type => current_user.type,
                    :sender_name => current_user.name,
                    :report_email_recipients => params[:report_email_recipients], 
                    :send_report_to_candidate => params[:send_report_to_candidate],
                    :send_sms => params[:send_sms],
                    :send_email => params[:send_email],
                    :worksheets => [{
                      :functional_area_id => params[:functional_area_id],
                      :candidate_stage => params[:candidate_stage],
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
    if request.put?
      params[:candidates] ||= {}
      params[:selected_candidates] ||= {}
      candidate_assessments = []
      failed_candidate_assessments = []
      recipient = params[:report_email_recipients]
      #if recipient.blank?
      #  flash[:error] = "Please enter valid email addresses for notification. Email addresses should be in the format 'abc@xyz.com'."
      #  render :action => :send_test_to_candidates and return
      #end
      if params[:selected_candidates].empty?
        flash[:error] = "Please select at least one candidate."
        render :action => :send_test_to_candidates and return
      end
      params[:selected_candidates].each do |candidate_id,on|
        candidate_assessment = @assessment.candidate_assessments.where(:query_options => { 
          :assessment_id => @assessment.id, 
          :candidate_id => candidate_id
        }).all[0]
        
        assessment_taker_type = Vger::Resources::Suitability::CandidateAssessment::AssessmentTakerType::REGULAR
        @candidate = Vger::Resources::Candidate.find(candidate_id)
        recipient = @candidate.email if params[:send_report_to_candidate]
        if recipient.present?
          recipient_regex = Regexp.new(recipient)
          if @candidate.email =~ recipient_regex
            assessment_taker_type = Vger::Resources::Suitability::CandidateAssessment::AssessmentTakerType::REPORT_RECEIVER
          end
        end
        options = {
          :assessment_taker_type => assessment_taker_type
        }
        # create candidate_assessment if not present
        # add it to list of candidate_assessments to send email
        unless candidate_assessment
          candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.create(:assessment_id => @assessment.id, :candidate_id => candidate_id, :candidate_stage => params[:candidate_stage], :responses_count => 0, :report_email_recipients => recipient, :options => options) 
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
        :send_sms => params[:send_sms],
        :send_email => params[:send_email]
      ) if candidate_assessments.present?
      if failed_candidate_assessments.present?
        #flash[:error] = "Cannot send test to #{failed_candidate_assessments.size} candidates.#{failed_candidate_assessments.first.error_messages.join('<br/>')}"
        #redirect_to candidates_url
        flash[:error] = "#{failed_candidate_assessments.first.error_messages.join('<br/>')}"
        render :action => :send_test_to_candidates and return
      else
        if @assessment.assessment_type == Vger::Resources::Suitability::CustomAssessment::AssessmentType::BENCHMARK
          flash[:notice] = "You have successfully sent the Benchmark!"
        else
          flash[:notice] = "Test was sent successfully!"
        end
        redirect_to candidates_url
      end
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
  end
  
  def send_reminder_to_candidate_url
    send_reminder_to_candidate_company_custom_assessment_path(:company_id => params[:company_id], :id => params[:id], :candidate_id => params[:candidate_id], :candidate_assessment_id => @candidate_assessment.id)
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
end
