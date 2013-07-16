class Suitability::RecommendationsController < ApplicationController
  before_filter :authenticate_user!
  
  layout "admin"
  
  def manage
  end
  
  def import_from_google_drive
    Vger::Resources::Suitability::Recommendation\
      .import_from_google_drive(params[:import])
    redirect_to suitability_recommendations_url, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Suitability::Recommendation\
      .export_to_google_drive(params[:export].merge(:columns => [:id,:body, :candidate_stage, :overall_fitment_grade_id]))
    redirect_to suitability_recommendations_url, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    @recommendations = Vger::Resources::Suitability::Recommendation.where(:page => params[:page], :per => 50, :methods => [:overall_fitment_grade]).all
  end
end
