class IndustriesController < ApplicationController
	before_filter :authenticate_user!

  layout "admin"
    	
	def import
		Vger::Resources::Industry.import(params[:file])
		redirect_to industries_url, notice: "Industrys imported."
	end	
	
	def manage
  end
  
	def import_from_google_drive
    Vger::Resources::Industry\
      .import_from_google_drive(params[:import])
    redirect_to industries_url, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
	end

  def export_to_google_drive
    Vger::Resources::Industry\
      .export_to_google_drive(params[:export].merge(:columns => ["id","name"]))
    redirect_to industries_url, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def show
    @industry = Vger::Resources::Industry.find(params[:id])
  end
  
  # GET /industrys
  def index
  	@industries = Vger::Resources::Industry.all
  end

  # GET /industrys/new
  # GET /industrys/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @industry }
    end
  end

  # POST /industrys
  # POST /industrys.json
  def create
    @industry = Vger::Resources::Industry.new(params[:industry])
			
    respond_to do |format|
      if @industry.save
        format.html { redirect_to @industry, notice: 'Industry was successfully created.' }
        format.json { render json: @industry, status: :created, location: @industry }
      else
        format.html { render action: "new" }
        format.json { render json: @industry.errors, status: :unprocessable_entity }
      end
    end
  end
end
