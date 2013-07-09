class AssessmentsController < ApplicationController
	before_filter :authenticate_user!
	before_filter :get_meta_data, :except => [:index, :show]
	
	layout "tests"

  def show
    #@assessment = Vger::Resources::Suitability::Assessment.find(params[:id])
  end
  
  def norms
    job_factor_norms = Vger::Resources::Suitability::Job::FactorNorm.where(:query_options => { :industry_id => params[:industry], :functional_area_id => params[:functional_area], :job_experience_id => params[:job_experience] }, :methods => [ :functional_area, :industry, :job_experience, :factor ]).all
	  @job_assessment_factor_norms = @assessment.job_assessment_factor_norms.all.collect{|a| a}
	  job_factor_norms.each do |job_factor_norm|
  	  @job_assessment_factor_norms.push Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(:functional_area_id => job_factor_norm.functional_area_id, :industry_id => job_factor_norm.industry_id, :job_experience_id => job_factor_norm.job_experience_id, :factor_id => job_factor_norm.factor_id) unless @assessment.job_assessment_factor_norms.map(&:factor_id).include? job_factor_norm.factor_id
  	end  
  	if request.put?  
      @assessment = Vger::Resources::Suitability::Assessment.save_existing(@assessment.id, params[:assessment])
      if @assessment.error_messages.blank?
        redirect_to styles_company_assessment_path(:company_id => params[:company_id], :id => @assessment.id, :functional_area => params[:functional_area], :industry => params[:industry], :job_experience => params[:job_experience]) and return
      else
        @assessment.error_messages << @assessment.errors.full_messages.dup
        @assessment.error_messages.flatten!
      end
    end  
  end
  
  def styles
    all_direct_predictor_parent_ids = Vger::Resources::Suitability::DirectPredictor.where(:methods => [ :parent ]).all.collect{|x| x.parent_id}.uniq
    all_direct_predictors = Vger::Resources::Suitability::Factor.where(:query_options => { :id => all_direct_predictor_parent_ids })
    
	  @job_assessment_factor_norms = @assessment.job_assessment_factor_norms.all.select{|x| all_direct_predictor_parent_ids.include? x.factor_id}
	  
	  selected_parents = @job_assessment_factor_norms.map(&:factor_id)
	  
	  all_direct_predictors.each do |factor|
  	  @job_assessment_factor_norms.push Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(:functional_area_id => params[:functional_area], :industry_id => params[:industry], :job_experience_id => params[:job_experience], :factor_id => factor.id) unless selected_parents.include? factor.id
  	end  
  	if request.put?  
      @assessment = Vger::Resources::Suitability::Assessment.save_existing(@assessment.id, params[:assessment])
      if @assessment.error_messages.blank?
        redirect_to add_candidates_company_assessment_path(:company_id => params[:company_id], :id => @assessment.id) and return
      else
        @assessment.error_messages << @assessment.errors.full_messages.dup
        @assessment.error_messages.flatten!
      end
    end  
  end
  
  def add_candidates
    @assessment = Vger::Resources::Suitability::Assessment.find(params[:id])
    @candidate_assessments ||= @assessment.candidate_assessments.to_a
    10.times do 
      @candidate_assessments.push(Vger::Resources::Suitability::CandidateAssessment.new(:assessment_id => params[:id]))
    end
  end
  
  # GET /assessments
  def index
  	@assessments = Vger::Resources::Suitability::Assessment.where(:page => params[:page], :per => 1)
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
        format.html { redirect_to norms_company_assessment_path(:company_id => params[:company_id], :id => @assessment.id, :functional_area => params[:functional_area], :industry => params[:industry], :job_experience => params[:job_experience]), notice: 'Assessment was successfully created.' }
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
  
  protected
  
  def get_meta_data
		if params[:id].present?
			@assessment = Vger::Resources::Suitability::Assessment.find(params[:id])
    else
      @assessment = Vger::Resources::Suitability::Assessment.new(params[:assessment])
      @assessment.assessable_type = "Company"
      @assessment.assessable_id = params[:company_id]
    end
	  @functional_areas = Vger::Resources::FunctionalArea.all
  	@industries = Vger::Resources::Industry.all
  	@job_experiences = Vger::Resources::JobExperience.all
  end
end
