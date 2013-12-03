class CandidateAssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_assessment
  before_filter :get_company
  
  layout "tests"
  
  def email_reports
    options = {
      :assessment => {
        :job_klass => "CandidateReportsExporter",
        :args => {
          :user_id => current_user.id,
          :assessment_id => params[:id]
        }
      }
    }
    Vger::Resources::Suitability::Assessment.find(params[:id])\
      .export_candidate_reports(options)
        
    redirect_to candidates_company_assessment_path(:company_id => params[:company_id], :id => params[:id]), notice: "Report summary will be generated and emailed to #{current_user.email}."
  end

  def bulk_upload
    s3_bucket_name = "bulk_upload_candidates_#{Rails.env.to_s}"
    s3_key = "candidates_#{@assessment.id}_#{Time.now.strftime("%d_%m_%Y_%H_%M_%P")}"
    unless params[:bulk_upload][:file]
      flash[:notice] = "Please select a csv file."
      redirect_to add_candidates_company_assessment_path(company_id: @company.id, id: @assessment.id) and return
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
    params[:candidates] = Hash[params[:candidates].collect{|key,data| [data[:email], data] }]
    params[:candidate_stage] ||= Vger::Resources::Candidate::Stage::EMPLOYED
    params[:upload_method] ||= "manual"
    @functional_areas = Vger::Resources::FunctionalArea.active.all.to_a
    if request.put?
      candidates = {}
      if params[:candidates].empty? 
        flash[:error] = "Please add at least one candidate to proceed."
        render :action => :add_candidates and return
      end
      errors = {}
      params[:candidates].each do |key,candidate_data|
        candidate = Vger::Resources::Candidate.where(:query_options => { :email => candidate_data[:email] }).all[0]
        errors[candidate_data[:name]] ||= []
        if candidate
          candidate_data[:id] = candidate.id
          candidates[candidate.id] = candidate_data
          attributes_to_update = candidate_data.dup
          attributes_to_update.each { |attribute,value| attributes_to_update.delete(attribute) unless candidate.send(attribute).blank? }
          Vger::Resources::Candidate.save_existing(candidate.id, attributes_to_update)
        else
          candidate = Vger::Resources::Candidate.create(candidate_data)
          if candidate.error_messages.present?
            errors[candidate_data[:name]] |= candidate.error_messages
          else
            candidate_data[:id] = candidate.id
            candidates[candidate.id] = candidate_data
          end
        end  
      end
      unless errors.values.flatten.empty?
        flash[:error] = "Errors in provided data: <br/>".html_safe
        flash[:error] += errors.map.with_index do |(candidate_name, candidate_errors), index| 
          if candidate_errors.present?
            ["Candidate #{index + 1}: #{candidate_errors.join(", ")}"]
          end  
        end.compact.join("<br/>").html_safe
        render :action => :add_candidates and return
      end
      params[:candidates] = candidates
      @company = Vger::Resources::Company.find(params[:company_id])
      render :action => :send_test_to_candidates
    end
  end
  
  # GET : renders send_reminder page
  # PUT : sends reminder and redirects to candidates list for current assessment
  def send_reminder
    if request.get?
      @candidate = Vger::Resources::Candidate.find(params[:candidate_id])
      @company = Vger::Resources::Company.find(params[:company_id])
      @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.where(:assessment_id => params[:id], :query_options => { :candidate_id => params[:candidate_id] }).all[0]
    elsif request.put?
      @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.send_reminder(params.merge(:assessment_id => params[:id], :id => params[:candidate_assessment_id]))
      flash[:notice] = "Reminder was sent successfully!"
      redirect_to candidates_company_assessment_path(:company_id => params[:company_id], :id => params[:id])
    end  
  end
  
  def bulk_send_test_to_candidates
    Vger::Resources::Candidate\
      .import_from_s3_files(:email => current_user.email,
                    :assessment_id => @assessment.id,
                    :sender_type => current_user.type,
                    :sender_name => current_user.name,
                    :report_email_recipients => params[:report_email_recipients], 
                    :worksheets => [{
                      :functional_area_id => params[:functional_area_id],
                      :candidate_stage => params[:candidate_stage],
                      :file => "BulkUpload.csv",
                      :bucket => params[:s3_bucket],
                      :key => params[:s3_key]
                    }]
                   )
    redirect_to candidates_company_assessment_path(:company_id => params[:company_id], :id => params[:id]), notice: "Candidates are being uploaded."             
  end
  
  # GET : renders send_test_to_candidates page
  # PUT : creates candidate assessments for selected candidates and sends test to candidates
  def send_test_to_candidates
    @company = Vger::Resources::Company.find(params[:company_id])
    if request.put?
      params[:candidates] ||= []
      candidate_assessments = []
      failed_candidate_assessments = []
      if params[:candidates].empty?
        @candidates = Vger::Resources::Candidate.where(:query_options => { :id => (params[:candidate_ids].split(",") rescue []) })
        flash[:error] = "Please select at least one candidate."
        render :action => :send_test_to_candidates and return
      end
      params[:candidates].each do |candidate_id,on|
        candidate_assessment = @assessment.candidate_assessments.where(:query_options => { 
          :assessment_id => @assessment.id, 
          :candidate_id => candidate_id
        }).all[0]
        # create candidate_assessment if not present
        # add it to list of candidate_assessments to send email
        unless candidate_assessment
          candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.create(:assessment_id => @assessment.id, :candidate_id => candidate_id, :candidate_stage => params[:candidate_stage], :responses_count => 0, :report_email_recipients => params[:report_email_recipients]) 
          if candidate_assessment.error_messages.present?
            failed_candidate_assessments << candidate_assessment
          else
            candidate_assessments.push candidate_assessment 
          end  
        end
      end
      assessment = Vger::Resources::Suitability::Assessment.send_test_to_candidates(:id => @assessment.id, :candidate_assessment_ids => candidate_assessments.map(&:id), :send_sms => params[:send_sms]) if candidate_assessments.present?
      if failed_candidate_assessments.present?
        flash[:alert] = "Cannot send test to #{failed_candidate_assessments.size} candidates. #{failed_candidate_assessments.first.error_messages.join('<br/>')}"
        redirect_to candidates_company_assessment_path(:company_id => params[:company_id], :id => params[:id])
      else
        flash[:notice] = "Test was sent successfully!"
        redirect_to candidates_company_assessment_path(:company_id => params[:company_id], :id => params[:id])
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
        order = "candidates.created_at DESC"
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
  
  # GET : renders candidate info for selected assessment
  def candidate
    @candidate = Vger::Resources::Candidate.find(params[:candidate_id], :include => [ :functional_area, :industry, :location ])
    @company = Vger::Resources::Company.find @assessment.assessable_id
    @candidate_assessments = Vger::Resources::Suitability::CandidateAssessment.where(:assessment_id => @assessment.id, :query_options => {
      :candidate_id => @candidate.id
    }, :include => [:candidate_assessment_reports])
  end
  
  protected
  
  # fetches assessment if id is present in params
  # creates new assessment otherwise
  def get_assessment
    @assessment = Vger::Resources::Suitability::Assessment.find(params[:id], :include => [:functional_area, :industry, :job_experience], :methods => [:competency_ids])
    if(@assessment.company_id.to_i == params[:company_id].to_i)
    else
      redirect_to root_path, alert: "Page you are looking for doesn't exist."
    end
  end
  
  def get_company
    methods = []
    if params[:action] == "index"
      if Rails.application.config.statistics[:load_assessmentwise_statistics]
        methods << :assessmentwise_statistics
      end
    end
    @company = Vger::Resources::Company.find(params[:company_id], :methods => methods)
  end
end
