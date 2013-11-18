class Suitability::FactorsController < ApplicationController
  before_filter :authenticate_user!

  def api_resource
    Vger::Resources::Suitability::Factor
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  layout "admin"

  def import
    Vger::Resources::Suitability::Factor.import(params[:file])
    redirect_to suitability_factors_path, notice: "Suitability Factors imported."
  end

  def manage
  end

  def import_from_google_drive
    Vger::Resources::Suitability::Factor\
      .import_from_google_drive(params[:import])
    redirect_to suitability_factors_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Suitability::Factor\
      .export_to_google_drive(params[:export].merge(:columns => ["uid","name","definition","type", "active"]))
    redirect_to suitability_factors_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    params[:type] ||= "Suitability::Factor"
    @factors = "Vger::Resources::#{params[:type]}".constantize.where(:page => params[:page], :per => 50, :include => [:parent], :methods => [:type]).all
  end

  # GET /factors/new
  # GET /factors/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /factors/:id
  # GET /factors/:id.json
  def show
    @factor = Vger::Resources::Suitability::Factor.find(params[:id], :root => :factor)
    respond_to do |format|
      format.html # new.html.erb
    end
  end
end
