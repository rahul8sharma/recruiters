class Suitability::PostAssessmentGuidelinesController < ApplicationController
  before_filter :authenticate_user!
  
  layout "admin"
  
  def manage
  end
  
  def import_from_google_drive
    Vger::Resources::Suitability::PostAssessmentGuideline\
      .import_from_google_drive(params[:import])
    redirect_to suitability_post_assessment_guidelines_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Suitability::PostAssessmentGuideline\
      .export_to_google_drive(params[:export].merge(:columns => [:id,:body, :candidate_stage, :factor_id]))
    redirect_to suitability_post_assessment_guidelines_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    @post_assessment_guidelines = Vger::Resources::Suitability::PostAssessmentGuideline.where(:page => params[:page], :per => 50, :methods => [:factor]).all
  end
end
