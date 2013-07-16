class FunctionalAreasController < ApplicationController
  before_filter :authenticate_user!
  
  layout "admin"
  
  def manage
  end
  
  def import_from_google_drive
    Vger::Resources::FunctionalArea\
      .import_from_google_drive(params[:import])
    redirect_to functional_areas_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::FunctionalArea\
      .export_to_google_drive(params[:export].merge(:columns => ["id","name"]))
    redirect_to functional_areas_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
  
  def import
    Vger::Resources::FunctionalArea.import(params[:file])
    redirect_to functional_areas_path, notice: "FunctionalAreas imported."
  end  

  def show
    @functional_area = Vger::Resources::FunctionalArea.find(params[:id])
  end
  
  # GET /functional_areas
  def index
    @functional_areas = Vger::Resources::FunctionalArea.all
  end

  # GET /functional_areas/new
  # GET /functional_areas/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @functional_area }
    end
  end

  # POST /functional_areas
  # POST /functional_areas.json
  def create
    @functional_area = Vger::Resources::FunctionalArea.new(params[:functional_area])
      
    respond_to do |format|
      if @functional_area.save
        format.html { redirect_to @functional_area, notice: 'FunctionalArea was successfully created.' }
        format.json { render json: @functional_area, status: :created, location: @functional_area }
      else
        format.html { render action: "new" }
        format.json { render json: @functional_area.errors, status: :unprocessable_entity }
      end
    end
  end
end
