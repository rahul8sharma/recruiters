class JobExperiencesController < ApplicationController
	before_filter :authenticate_user!
	
	def import
		Vger::Resources::JobExperience.import(params[:file])
		redirect_to job_experiences_url, notice: "JobExperiences imported."
	end	
	
	def manage
  end
  
	def import_from_google_drive
    Vger::Resources::JobExperience\
      .import_from_google_drive(params[:import])
    redirect_to job_experiences_url, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
	end

  def export_to_google_drive
    Vger::Resources::JobExperience\
      .export_to_google_drive(params[:export].merge(:columns => ["id","display_text","max","min"]))
    redirect_to job_experiences_url, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def show
    @job_experience = Vger::Resources::JobExperience.find(params[:id])
  end
  
  # GET /job_experiences
  def index
  	@job_experiences = Vger::Resources::JobExperience.all
  end

  # GET /job_experiences/new
  # GET /job_experiences/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @job_experience }
    end
  end

  # POST /job_experiences
  # POST /job_experiences.json
  def create
    @job_experience = Vger::Resources::JobExperience.new(params[:job_experience])
			
    respond_to do |format|
      if @job_experience.save
        format.html { redirect_to @job_experience, notice: 'JobExperience was successfully created.' }
        format.json { render json: @job_experience, status: :created, location: @job_experience }
      else
        format.html { render action: "new" }
        format.json { render json: @job_experience.errors, status: :unprocessable_entity }
      end
    end
  end
end
