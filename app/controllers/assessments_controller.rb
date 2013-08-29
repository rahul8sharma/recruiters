class AssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_assessment, :except => [:index]
  before_filter :get_meta_data, :only => [:new, :norms]
  before_filter :get_company
  
  
  layout "tests"

  def show
    @assessment = Vger::Resources::Suitability::Assessment.find(params[:id])
    @assessment_factor_norms = @assessment.job_assessment_factor_norms.where(:methods => [:functional_area, :industry, :job_experience, :from_norm_bucket, :to_norm_bucket], :include => { :factor => { :methods => [:type, :direct_predictor_ids] } }).all.to_a
    
    direct_predictor_parent_ids = @assessment_factor_norms.collect{ |x| x.factor.direct_predictor_ids.present? ? x.factor_id : nil }.compact.uniq
    direct_predictor_norms = @assessment_factor_norms.select{ |x| direct_predictor_parent_ids.include? x.factor_id }.uniq
    alarm_factor_norms = @assessment_factor_norms.select{ |x| x.factor.type == "Suitability::AlarmFactor" }.uniq
    @assessment_factor_norms = @assessment_factor_norms - direct_predictor_norms
    @other_norms = direct_predictor_norms
  end


  # fetches norms data
  # GET : renders norms when request method is get
  # PUT : updates assessment and renders styles
  def norms
    if request.get?
      if params[:assessment]
        @assessment = Vger::Resources::Suitability::Assessment.save_existing(@assessment.id, params[:assessment])
      end
      get_norms
    elsif request.put?  
      get_norms
      params[:assessment][:job_assessment_factor_norms_attributes] ||= {}
      if !params[:assessment][:job_assessment_factor_norms_attributes].select{|index,data| data[:_destroy] != "true" }.present?
        flash[:error] = "Please select at least one factor to proceed."
        return
      else
        params[:assessment][:job_assessment_factor_norms_attributes].each do |index, factor_norms_attributes|
          norm_buckets_by_id = Hash[@norm_buckets.collect{|norm_bucket| [norm_bucket.id,norm_bucket] }]
          if factor_norms_attributes[:from_norm_bucket_id]
            from_weight = norm_buckets_by_id[factor_norms_attributes[:from_norm_bucket_id].to_i].weight
            to_weight = norm_buckets_by_id[factor_norms_attributes[:to_norm_bucket_id].to_i].weight
            if from_weight > to_weight
              flash[:error] = "Upper Limit in the Desired/Acceptable Score Range must be of a greater value than the selected Lower Limit."
              return
            end
          end
        end
        @assessment = Vger::Resources::Suitability::Assessment.save_existing(@assessment.id, params[:assessment])
        if @assessment.error_messages.blank?
          #get_styles
          #render :styles
          redirect_to styles_company_assessment_path(:company_id => params[:company_id], :id => @assessment.id)          
        else
          flash[:error] = @assessment.error_messages.join("<br/>")
        end
      end  
    end
  end
  
  # fetches styles data
  # GET : renders styles
  # PUT : updates assessment and redirects to add_candidates
  def styles
    get_styles
    if request.put?  
      params[:assessment] ||= {}
      @assessment = Vger::Resources::Suitability::Assessment.save_existing(@assessment.id, params[:assessment])
      if @assessment.error_messages.blank?
        Vger::Resources::Suitability::Set.create(Rails.application.config.default_set.merge(:assessment_id => @assessment.id, :end_index => @assessment.item_ids.count))
        redirect_to add_candidates_company_assessment_path(:company_id => params[:company_id], :id => @assessment.id) and return
      else
        @assessment.error_messages << @assessment.errors.full_messages.dup
        @assessment.error_messages.flatten!
        flash[:error] = @assessment.error_messages.join("<br/>")
      end
    end  
  end
  
  # GET : renders form to add candidates
  # PUT : creates candidates and renders send_test_to_candidates
  def add_candidates
    params[:candidates] ||= {}
    params[:candidates].reject!{|key,data| data[:email].blank? && data[:name].blank?}
    params[:candidates] = Hash[params[:candidates].collect{|key,data| [data[:email], data] }]
    @functional_areas = Vger::Resources::FunctionalArea.all.to_a
    if request.put?
      candidates = {}
      if params[:candidates].empty? 
        flash[:error] = "Please add at least one candidate to proceed."
        render :action => :add_candidates and return
      end
      if params[:candidates].find{|key,data| data[:name].blank? || data[:email].blank? }.present?
        flash[:error] = "Please enter full name as well as email id of the candidates you want to send the test to."
        render :action => :add_candidates and return
      end
      errors = {}
      
      params[:candidates].each do |key,candidate_data|
        candidate = Vger::Resources::Candidate.where(:query_options => { :email => candidate_data[:email] }).all[0]
        if candidate
          candidate_data[:id] = candidate.id
          candidates[candidate.id] = candidate_data
          attributes_to_update = candidate_data.dup
          attributes_to_update.each { |attribute,value| attributes_to_update.delete(attribute) unless candidate.send(attribute).blank? }
          Vger::Resources::Candidate.save_existing(candidate.id, attributes_to_update)
        else
          candidate = Vger::Resources::Candidate.create(candidate_data)
          if candidate.error_messages.present?
            errors[candidate.email] ||= []
            errors[candidate.email] |= candidate.error_messages
          else
            candidate_data[:id] = candidate.id
            candidates[candidate.id] = candidate_data
          end
        end  
        unless errors.empty?
          flash[:error] = "Invalid data. Please ensure that email addresses and phone numbers provided are in the correct format."
          render :action => :add_candidates and return
        end
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
  
  # GET : renders send_test_to_candidates page
  # PUT : creates candidate assessments for selected candidates and sends test to candidates
  def send_test_to_candidates
    @company = Vger::Resources::Company.find(params[:company_id])
    if request.put?
      params[:candidates] ||= []
      candidate_assessments = []
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
          candidate_assessments.push candidate_assessment 
        end
      end
      assessment = Vger::Resources::Suitability::Assessment.send_test_to_candidates(:id => @assessment.id, :candidate_assessment_ids => candidate_assessments.map(&:id)) if candidate_assessments.present?
      flash[:notice] = "Test was sent successfully!"
      redirect_to candidates_company_assessment_path(:company_id => params[:company_id], :id => params[:id])
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
    scope = Vger::Resources::Suitability::CandidateAssessment.where(:assessment_id => @assessment.id).where(:page => params[:page], :per => 10, :joins => :candidate, :order => order).where(:include => :candidate).where(:methods => [:candidate_assessment_reports])
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
    @candidate = Vger::Resources::Candidate.find(params[:candidate_id], :methods => [ :functional_area, :industry, :location ])
    @company = Vger::Resources::Company.find @assessment.assessable_id
    @candidate_assessments = Vger::Resources::Suitability::CandidateAssessment.where(:assessment_id => @assessment.id, :query_options => {
      :candidate_id => @candidate.id
    }, :methods => [:candidate_assessment_reports])
  end
  
  # GET /assessments
  def index
    @assessments = Vger::Resources::Suitability::Assessment.where(:query_options => { :assessable_id => params[:company_id], :assessable_type => "Company" }, :order => "created_at DESC", :page => params[:page], :per => 10)
  end
  
  # GET /assessments/new
  # GET /assessments/new.json
  def new
  end

  # POST /assessments
  # POST /assessments.json
  # POST creates assessment and redirects to norms page
  def create
    default_norm_bucket_ranges = get_default_norm_bucket_ranges
    flash[:alert] = "There are no default norms for this criteria. Please select another criterita or try after adding the required data." if default_norm_bucket_ranges.empty?                                    
    respond_to do |format|
      if default_norm_bucket_ranges.present? and @assessment.valid? and @assessment.save
        format.html { redirect_to norms_company_assessment_path(:company_id => params[:company_id], :id => @assessment.id) }
      else
        get_meta_data
        flash[:error] = @assessment.errors.values.flatten.join(",") rescue ""
        format.html { render action: "new" }
      end
    end
  end
 
  protected
  
  # fetches assessment if id is present in params
  # creates new assessment otherwise
  def get_assessment
    if params[:id].present?
      @assessment = Vger::Resources::Suitability::Assessment.find(params[:id], :methods => [:functional_area, :industry, :job_experience])
    else
      @assessment = Vger::Resources::Suitability::Assessment.new(params[:assessment])
      @assessment.assessable_type = "Company"
      @assessment.assessable_id = params[:company_id]
    end
  end
  
  # fetches meta data for new assessment and adding norms to existing assessment 
  def get_meta_data
    factors = Vger::Resources::Suitability::Factor.where(:methods => [:type]).all.to_a
    factors |= Vger::Resources::Suitability::AlarmFactor.where(:methods => [:type]).all.to_a
    @factors = Hash[factors.collect{|x| [x.id,x]}]
    @functional_areas = Hash[Vger::Resources::FunctionalArea.all.to_a.collect{|x| [x.id,x]}]
    @industries = Hash[Vger::Resources::Industry.all.to_a.collect{|x| [x.id,x]}]
    @job_experiences = Hash[Vger::Resources::JobExperience.all.to_a.collect{|x| [x.id,x]}]
  end
  
  # fetches default factor norms
  # fetches norm buckets for dropdowns
  # fetches default_norm_bucket_ranges for the assessment's FA, Industry and Exp
  # creates job_assessment_factor_norm for each factor with default values   
  def get_norms
    @norm_buckets = Vger::Resources::Suitability::NormBucket.where(:order => "weight ASC").all
    @fits = Vger::Resources::Suitability::Fit.all
    
    default_norm_bucket_ranges = get_default_norm_bucket_ranges
    
                                    
    added_factors = @assessment.job_assessment_factor_norms.where(:include => { :factor => { :methods => [:type] } }).all.to_a
    added_factor_ids = added_factors.map(&:factor_id)
    @factor_norms_by_fit = {}
    @fits.each do |fit|
      norms_by_fit = default_norm_bucket_ranges.select{|default_norm| fit.factor_ids.include? (default_norm.factor_id)}  
      
      assessment_factor_norms = added_factors.select{|assessment_norm| fit.factor_ids.include? (assessment_norm.factor_id)}

      factors_by_fit = @factors.select{|id,factor| fit.factor_ids.include? id }.values      
      
      @factor_norms_by_fit[fit] = {
        :factors => assessment_factor_norms.select{|x| x.factor.type == 'Suitability::Factor'}, 
        :alarm_factors => assessment_factor_norms.select{|x| x.factor.type == 'Suitability::AlarmFactor'}
      }
      
      factors_by_fit.each do |factor|
        default_norm_bucket_range = default_norm_bucket_ranges.find{|x| x.factor_id == factor.id}
        #next if @factors[default_norm_bucket_range.factor_id].nil?
        if default_norm_bucket_range
          assessment_factor_norm = Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(
            default_norm_bucket_range.attributes.except("created_at","updated_at","id").\
               merge(:from_norm_bucket_id => default_norm_bucket_range.from_norm_bucket_id, 
                     :to_norm_bucket_id => default_norm_bucket_range.to_norm_bucket_id)
          )
        else
          assessment_factor_norm = Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(
            :from_norm_bucket_id => @norm_buckets.first.id, 
            :to_norm_bucket_id => @norm_buckets.last.id,
            :factor_id => factor.id,
            :functional_area_id => @assessment.functional_area_id,
            :industry_id => @assessment.industry_id,
            :job_experience_id => @assessment.job_experience_id
          )
          
        end
        
        # to avoid calls to API, set fa, industry and exp from already fetched data
        assessment_factor_norm.functional_area = @functional_areas[@assessment.functional_area_id]
        assessment_factor_norm.industry = @industries[@assessment.industry_id]
        assessment_factor_norm.job_experience = @job_experiences[@assessment.job_experience_id]
        assessment_factor_norm.factor = @factors[factor.id]
        
        unless added_factor_ids.include? factor.id
          if assessment_factor_norm.factor.type == 'Suitability::AlarmFactor'
            @factor_norms_by_fit[fit][:alarm_factors] << assessment_factor_norm  
          else
            @factor_norms_by_fit[fit][:factors] << assessment_factor_norm  
          end
        end
      end  
    end
    if default_norm_bucket_ranges.empty?
      flash[:alert] = "There are no default norms for this criteria. Please add the required data."
    end
  end
  
  
  # fetch styles data
  # fetch all direct predictors
  # fetch parents of all direct predictors
  # fetch all alarm factors
  # create new job_assessment_factor_norm for each factor
  def get_styles
    @norm_buckets = Vger::Resources::Suitability::NormBucket.all
    all_direct_predictor_parent_ids = Vger::Resources::Suitability::DirectPredictor.where(:query_options => { :type => "Suitability::DirectPredictor" }, :methods => [ :parent ]).to_a.map(&:parent_id).uniq
    
    all_direct_predictors = Vger::Resources::Suitability::Factor.where(:query_options => { :id => all_direct_predictor_parent_ids }).to_a
    
    @job_assessment_factor_norms = @assessment.job_assessment_factor_norms.where(:include => { :factor => { :methods => [:type] } }).all.select{|x| all_direct_predictor_parent_ids.include? x.factor_id}
    
    selected_parents = @job_assessment_factor_norms.map(&:factor_id)
    
    all_direct_predictors.each do |factor|
      assessment_factor_norm = Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(:functional_area_id => @assessment.functional_area_id, :industry_id => @assessment.industry_id, :job_experience_id => @assessment.job_experience_id, :factor_id => factor.id)
      assessment_factor_norm.factor = factor
      @job_assessment_factor_norms.push assessment_factor_norm unless selected_parents.include? factor.id
    end  
  end
  
  def get_default_norm_bucket_ranges
    query_options = { 
      :functional_area_id => @assessment.functional_area_id,
      :industry_id => @assessment.industry_id,
      :job_experience_id => @assessment.job_experience_id
    }
    default_norm_bucket_ranges = Vger::Resources::Suitability::DefaultFactorNormRange.\
                                    where(:query_options => query_options).all.to_a
  end
  
  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [ :assessmentwise_statistics ])
  end
end
