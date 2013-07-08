class AssessmentsController < ApplicationController
	before_filter :authenticate_user!
	before_filter :get_meta_data, :except => [:index, :show, :norms, :styles]
	
  def show
    #@assessment = Vger::Resources::Suitability::Assessment.find(params[:id])
  end
  
  def norms
  end
  
  def styles
  end
  
  # GET /assessments
  def index
  	@assessments = Vger::Resources::Suitability::Assessment.all
  end
  
  # GET /assessments/new
  # GET /assessments/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @assessment }
    end
  end

  # POST /assessments
  # POST /assessments.json
  def create
    respond_to do |format|
      if @assessment.valid? and @assessment.save
        format.html { redirect_to company_assessment_path(:company_id => params[:company_id], :id => @assessment.id), notice: 'Assessment was successfully created.' }
        format.json { render json: @assessment, status: :created, location: @job }
      else
        format.html { render action: "new" }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
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
			@job_assessment_factor_norms = @assessment.job_assessment_factor_norms  	
		elsif params[:assessment].present?
			if params[:assessment][:assessable_type].blank? || params[:assessment][:assessable_id].blank?
				flash[:notice] = "You must select assessable entity first"
				redirect_to company_assessments_path(:company_id => params[:company_id], ) and return
			end
			@assessment = Vger::Resources::Suitability::Assessment.new(params[:assessment])
			job_factor_norms = Vger::Resources::Suitability::Job::FactorNorm.where(:query_options => { :industry_id => params[:industry], :functional_area_id => params[:functional_area], :job_experience_id => params[:job_experience] }).all
  		@job_assessment_factor_norms = []
  		job_factor_norms.each do |job_factor_norm|
  			@job_assessment_factor_norms.push Vger::Resources::Suitability::Job::AssessmentFactorNorm.new(job_factor_norm.attributes.except(:id,:created_at,:updated_at))
  		end
  		@assessable = "Vger::Resources::#{@assessment.assessable_type}".constantize.where(:methods => [:functional_areas, :industries]).find(@assessment.assessable_id)
		  @functional_areas = @assessable.functional_areas
    	@industries = @assessable.industries
    	@job_experiences = [@assessable.job_experience]
		end
  end
end
