class Suitability::NormBucketsController < ApplicationController
  before_filter :authenticate_user!
  
  layout "admin"
  
  def manage
  end
  
  def import_from_google_drive
    Vger::Resources::Suitability::NormBucket\
      .import_from_google_drive(params[:import])
    redirect_to suitability_norm_buckets_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Suitability::NormBucket\
      .export_to_google_drive(params[:export].merge(:columns => [:id,:uid, :name]))
    redirect_to suitability_norm_buckets_buckets_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    @norm_buckets = Vger::Resources::Suitability::NormBucket.where(:page => params[:page], :per => 50).all
  end
end
