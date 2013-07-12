class AssessmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_assessment, :except => [:index]
  before_filter :get_meta_data, :only => [:new, :norms]
  
  layout "tests"

  def show
    @assessment = Vger::Resources::Suitability::Assessment.find(params[:id])
    @assessment_factor_norms = @assessment.job_assessment_factor_norms.where(:methods => [:factor, :functional_area, :industry, :job_experience]).all.to_a
  end
  
  def norms
    get_norms
    if params[:assessment]
      @assessment = Vger::Resources::Suitability::Assessment.save_existing(@assessment.id, params[:assessment])
    end
    if request.put?  
      if @assessment.error_messages.blank?
        get_styles
        render :styles
      else
        @assessment.error_messages << @assessment.errors.full_messages.dup
      end
    end
  end
  
  def styles
    get_styles
    if request.put?  
      @assessment = Vger::Resources::Suitability::Assessment.save_existing(@assessment.id, params[:assessment])
      if @assessment.error_messages.blank?
        redirect_to add_candidates_company_assessment_path(:company_id => params[:company_id], :id => @assessment.id) and return
      else
        @assessment.error_messages << @assessment.errors.full_messages.dup
        @assessment.error_messages.flatten!
        Rails.logger.ap @assessment.error_messages
        flash[:notice] = @assessment.error_messages.join("<br/>")
      end
    end  
  end
  
  def add_candidates
    params[:candidates].reject!{|key,data| data[:email].blank?} if params[:candidates]
    if request.put?
      @candidates = []
      params[:candidates].each do |key,candidate_data|
        candidate = Vger::Resources::Candidate.where(:query_options => { :email => candidate_data[:email] }).all[0]
        candidate = Vger::Resources::Candidate.create(candidate_data) unless candidate
        @candidates.push candidate
      end
      @company = Vger::Resources::Company.find(params[:company_id])
      render :action => :send_test_to_candidates
    end
  end
  
  def candidates
    ids = @assessment.candidate_assessments.where(:page => params[:page], :per => 10).map(&:candidate_id)
    @candidates = Vger::Resources::Candidate.where(:query_options=> {:id => ids.present? ? ids : -1})
  end
  
  def candidate
    @candidate = Vger::Resources::Candidate.find(params[:candidate_id], :methods => [ :functional_area, :industry, :location ])
    @company = Vger::Resources::Company.find @assessment.assessable_id
    @candidate_assessments = Vger::Resources::Suitability::CandidateAssessment.where(:assessment_id => @assessment.id, :query_options => {
      :candidate_id => @candidate.id
    })
  end
  
  def send_reminder
    if request.get?
      @candidate = Vger::Resources::Candidate.find(params[:candidate_id])
      @company = Vger::Resources::Company.find(params[:company_id])
      @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.where(:assessment_id => params[:id], :query_options => { :candidate_id => params[:candidate_id] }).all[0]
    elsif request.put?
      @candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.send_reminder(params.merge(:assessment_id => params[:id]))
      flash[:notice] = "Reminder sent to candidate successfully."
      redirect_to candidates_company_assessment_path(:company_id => params[:company_id], :id => params[:id])
    end  
  end
  
  def send_test_to_candidates
    @company = Vger::Resources::Company.find(params[:company_id])
    if request.put?
      params[:candidates] ||= []
      candidate_assessments = []
      params[:candidates].each do |candidate_id,on|
        candidate_assessment = @assessment.candidate_assessments.where(:query_options => { 
          :assessment_id => @assessment.id, 
          :candidate_id => candidate_id
        }).all[0]
        
        candidate_assessment = Vger::Resources::Suitability::CandidateAssessment.create(:assessment_id => @assessment.id, :candidate_id => candidate_id, :candidate_stage => params[:candidate_stage], :responses_count => 0) unless candidate_assessment
        candidate_assessments.push candidate_assessment 
      end
      assessment = Vger::Resources::Suitability::Assessment.send_test_to_candidates(:id => @assessment.id, :candidate_assessment_ids => candidate_assessments.map(&:id)) if candidate_assessments.present?
      flash[:notice] = "You have successfully sent the test!!"
      redirect_to company_assessment_path(:company_id => params[:company_id], :id => @assessment.id)
    end
  end
  
  # GET /assessments
  def index
    @assessments = Vger::Resources::Suitability::Assessment.where(:query_options => { :assessable_id => params[:company_id], :assessable_type => "Company" }, :page => params[:page], :per => 10)
  end
  
  # GET /assessments/new
  # GET /assessments/new.json
  def new
  end

  # POST /assessments
  # POST /assessments.json
  def create
    respond_to do |format|
      if @assessment.valid? and @assessment.save
        format.html { redirect_to norms_company_assessment_path(:company_id => params[:company_id], :id => @assessment.id), notice: 'Assessment was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end
  
  # GET /assessments/:id
  # GET /assessments/:id.json
  def edit
    respond_to do |format|
      format.html
    end
  end
  
  # PUT /assessments/:id
  # PUT /assessments/:id.json
  def update
    respond_to do |format|
      if Vger::Resources::Suitability::Assessment.save_existing(params[:id], params[:assessment])
        format.html { redirect_to company_assessment_path(:company_id => params[:company_id], :id => params[:id]), notice: 'Suitability Assessment was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end
  
  def assessment_report
    respond_to do |format|
      format.html { render :layout => "reports" }
      format.pdf { render :pdf => "report", :layout => "reports.html.haml", :template => "assessments/assessment_report.pdf.haml" }
    end
  end
  
  protected
  
  def get_assessment
    if params[:id].present?
      @assessment = Vger::Resources::Suitability::Assessment.find(params[:id], :methods => [:functional_area, :industry, :job_experience])
    else
      @assessment = Vger::Resources::Suitability::Assessment.new(params[:assessment])
      @assessment.assessable_type = "Company"
      @assessment.assessable_id = params[:company_id]
    end
  end
  
  def get_meta_data
    @factors = Hash[Vger::Resources::Suitability::Factor.where(:page => 1, :per => 100).all.to_a.collect{|x| [x.id,x]}]
    @functional_areas = Hash[Vger::Resources::FunctionalArea.where(:page => 1, :per => 100).all.to_a.collect{|x| [x.id,x]}]
    @industries = Hash[Vger::Resources::Industry.where(:page => 1, :per => 100).all.to_a.collect{|x| [x.id,x]}]
    @job_experiences = Hash[Vger::Resources::JobExperience.where(:page => 1, :per => 100).all.to_a.collect{|x| [x.id,x]}]
  end
  
  def get_norms
    @norm_buckets = Vger::Resources::Suitability::NormBucket.all
    
    default_norm_bucket_ranges = Vger::Resources::Suitability::DefaultFactorNormRange.\
                                    where(:query_options => { 
                                      :functional_area_id => @assessment.functional_area_id,
                                      :industry_id => @assessment.industry_id,
                                      :job_experience_id => @assessment.job_experience_id
                                    }, :page => 1, :per => 100).all
    
    @job_assessment_factor_norms = @assessment.job_assessment_factor_norms.where(:methods =>[ :factor ], :page => 1, :per => 100).all.to_a
    added_factor_ids = @job_assessment_factor_norms.map(&:factor_id)
    default_norm_bucket_ranges.each do |default_norm_bucket_range|
      next if @factors[default_norm_bucket_range.factor_id].nil?
      
      assessment_factor_norm = Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(
        default_norm_bucket_range.attributes.except("created_at","updated_at","id").\
           merge(:from_norm_bucket_id => default_norm_bucket_range.from_norm_bucket_id, 
                 :to_norm_bucket_id => default_norm_bucket_range.to_norm_bucket_id)
      )
      
      # to avoid calls to API, set fa, industry and exp from already fetched data
      assessment_factor_norm.functional_area = @functional_areas[default_norm_bucket_range.functional_area_id]
      assessment_factor_norm.industry = @industries[default_norm_bucket_range.industry_id]
      assessment_factor_norm.job_experience = @job_experiences[default_norm_bucket_range.job_experience_id]
      assessment_factor_norm.factor = @factors[default_norm_bucket_range.factor_id]
      
      @job_assessment_factor_norms.push assessment_factor_norm unless added_factor_ids.include? default_norm_bucket_range.factor_id
    end  
  end
  
  def get_styles
    all_direct_predictor_parent_ids = Vger::Resources::Suitability::DirectPredictor.where(:query_options => { :type => "Suitability::DirectPredictor" }, :methods => [ :parent ]).all.map(&:parent_id).uniq
    
    alarm_factors = Vger::Resources::Suitability::AlarmFactor.all.to_a
    
    all_direct_predictor_parent_ids
    
    all_direct_predictors = Vger::Resources::Suitability::Factor.where(:query_options => { :id => all_direct_predictor_parent_ids })
    
    all_direct_predictors |= alarm_factors
    
    @job_assessment_factor_norms = @assessment.job_assessment_factor_norms.all.select{|x| all_direct_predictor_parent_ids.include? x.factor_id}
    
    selected_parents = @job_assessment_factor_norms.map(&:factor_id)
    
    all_direct_predictors.each do |factor|
      assessment_factor_norm = Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(:functional_area_id => @assessment.functional_area_id, :industry_id => @assessment.industry_id, :job_experience_id => @assessment.job_experience_id, :factor_id => factor.id)
      assessment_factor_norm.factor = factor
      @job_assessment_factor_norms.push assessment_factor_norm unless selected_parents.include? factor.id
    end  
  end
end
