class Suitability::FitsController < ApplicationController
  before_filter :authenticate_user!
  
  layout "admin"
  
  def manage
  end
  
  def import_from_google_drive
    Vger::Resources::Suitability::Fit\
      .import_from_google_drive(params[:import])
    redirect_to suitability_fits_url, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Suitability::Fit\
      .export_to_google_drive(params[:export].merge(:columns => [:id,:factor_ids, :name]))
    redirect_to suitability_fits_url, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    @fits = Vger::Resources::Suitability::Fit.where(:page => params[:page], :per => 50).all
  end
end
