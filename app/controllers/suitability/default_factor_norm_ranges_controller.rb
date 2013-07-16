class Suitability::DefaultFactorNormRangesController < ApplicationController
  before_filter :authenticate_user!
  
  layout "admin"
  
  def manage
  end
  
  def import_from_google_drive
    Vger::Resources::Suitability::DefaultFactorNormRange\
      .import_from_google_drive(params[:import])
    redirect_to suitability_default_factor_norm_ranges_url, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Suitability::DefaultFactorNormRange\
      .export_to_google_drive(params[:export].merge(:columns => [:id,:factor_ids, :name]))
    redirect_to suitability_default_factor_norm_ranges_url, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    @default_factor_norm_ranges = Vger::Resources::Suitability::DefaultFactorNormRange.where(:page => params[:page], :per => 50).all
  end
end
