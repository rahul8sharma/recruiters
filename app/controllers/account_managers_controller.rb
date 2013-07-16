class AccountManagersController < ApplicationController
	before_filter :authenticate_user!
	
  def import
		Vger::Resources::AccountManager.import(params[:file])
		redirect_to account_managers_path, notice: "Account Managers imported."
	end	

  def manage
  end
  
	def import_from_google_drive
    Vger::Resources::AccountManager\
      .import_from_google_drive(params[:import])
    redirect_to account_managers_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
	end

  def export_to_google_drive
    Vger::Resources::AccountManager\
      .export_to_google_drive(params[:export].merge(:columns => ["id","name","email"]))
    redirect_to account_managers_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def assign_jobs_form
  end

  def assign_jobs
    Vger::Resources::AccountManager.import_jobs(params[:file])
    redirect_to account_managers_path, notice: "Jobs assigned."
  end
  
  # GET /account_managers
  def index
  	@account_managers = Vger::Resources::AccountManager.where(:page => params[:page], :per => 10)
  end

  # GET /account_managers/new
  # GET /account_managers/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @account_manager }
    end
  end

  # POST /account_managers
  # POST /account_managers.json
  def create
    # @account_manager = AccountManager.new(params[:account_manager])

    # respond_to do |format|
    #   if @account_manager.save
    #     format.html { redirect_to @account_manager, notice: 'Account manager was successfully created.' }
    #     format.json { render json: @account_manager, status: :created, location: @account_manager }
    #   else
    #     format.html { render action: "new" }
    #     format.json { render json: @account_manager.errors, status: :unprocessable_entity }
    #   end
    # end
  end
end
