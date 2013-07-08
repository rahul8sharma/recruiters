class HiringManagersController < ApplicationController
  before_filter :authenticate_user!

  def import
		Vger::Resources::HiringManager.import(params[:file])
		redirect_to hiring_managers_url, notice: "HiringManagers imported."
	end	

  def assign_jobs_form
    
  end

  def assign_jobs
    Vger::Resources::HiringManager.import_jobs(params[:file])
    redirect_to hiring_managers_path, notice: "Jobs assigned."
  end
  
  # GET /hiring_managers
  def index
  	@hiring_managers = Vger::Resources::HiringManager.all
  end

  # GET /hiring_managers/new
  # GET /hiring_managers/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @hiring_manager }
    end
  end
end
