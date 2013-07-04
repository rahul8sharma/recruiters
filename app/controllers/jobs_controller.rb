class JobsController < ApplicationController
	before_filter :authenticate_user!
	
	def import
		@errors = Vger::Resources::Job.import(params[:file])
		redirect_to jobs_url, notice: "Jobs imported."
	end	
	
	def manage
  end
  
	def import_from_google_drive
    Vger::Resources::Job\
      .import_from_google_drive(params[:import])
    redirect_to jobs_url, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
	end

  def export_to_google_drive
    Vger::Resources::Job\
      .export_to_google_drive(params[:export].merge(:columns => [:title, :description]))
    redirect_to jobs_url, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
	
  def show
    @job = Vger::Resources::Job.find(params[:id])
  end
  
  # GET /jobs
  def index
  	@jobs = Vger::Resources::Job.all
  end
  
  # GET /jobs/new
  # GET /jobs/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @job }
    end
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @job = Vger::Resources::Job.new(params[:job])
			
    respond_to do |format|
      if @job.save
        format.html { redirect_to @job, notice: 'Job was successfully created.' }
        format.json { render json: @job, status: :created, location: @job }
      else
        format.html { render action: "new" }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end
end
