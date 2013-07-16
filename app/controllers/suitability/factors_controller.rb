class Suitability::FactorsController < ApplicationController
  before_filter :authenticate_user!
  
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
      .export_to_google_drive(params[:export].merge(:columns => ["id","uid","name","definition","type","parent_id"]))
    redirect_to suitability_factors_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    @factors = Vger::Resources::Suitability::Factor.where(:page => params[:page], :per => 50, :methods => [:type, :parent]).all
    @direct_predictors = Vger::Resources::Suitability::DirectPredictor.where(:page => params[:page], :per => 50, :methods => [:type, :parent]).all
    @alarm_factors = Vger::Resources::Suitability::AlarmFactor.where(:page => params[:page], :per => 50, :methods => [:type, :parent]).all
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
    @factor = Vger::Resources::Suitability::Factor.find(params[:id])
    respond_to do |format|
      format.html # new.html.erb
    end
  end
end
