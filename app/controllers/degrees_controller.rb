class DegreesController < ApplicationController
  before_filter :authenticate_user!

  def api_resource
    Vger::Resources::Degree
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  layout "admin"

  def import
    Vger::Resources::Degree.import(params[:file])
    redirect_to degrees_path, notice: "Degrees imported."
  end

  def manage
  end

  def import_from_google_drive
    Vger::Resources::Degree\
      .import_from_google_drive(params[:import])
    redirect_to degrees_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Degree\
      .export_to_google_drive(params[:export].merge(:columns => ["id","name"]))
    redirect_to degrees_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def show
    @degree = Vger::Resources::Degree.find(params[:id])
  end

  # GET /degrees
  def index
    @degrees = Vger::Resources::Degree.where(:page => params[:page], :per => 10)
  end

  # GET /degrees/new
  # GET /degrees/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @degree }
    end
  end

  # POST /degrees
  # POST /degrees.json
  def create
    @degree = Vger::Resources::Degree.new(params[:degree])

    respond_to do |format|
      if @degree.save
        format.html { redirect_to @degree, notice: 'Degree was successfully created.' }
        format.json { render json: @degree, status: :created, location: @degree }
      else
        format.html { render action: "new" }
        format.json { render json: @degree.errors, status: :unprocessable_entity }
      end
    end
  end
end
