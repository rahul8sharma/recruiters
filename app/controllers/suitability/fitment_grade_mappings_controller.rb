class Suitability::FitmentGradeMappingsController < ApplicationController
  before_filter :authenticate_user!
  
  layout "admin"
  
  def manage
  end
  
  def import_from_google_drive
    Vger::Resources::Suitability::FitmentGradeMapping\
      .import_from_google_drive(params[:import])
    redirect_to suitability_fitment_grade_mappings_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Suitability::FitmentGradeMapping\
      .export_to_google_drive(params[:export].merge(:columns => [:id, :fitment_grades, :overall_fitment_grade_id]))
    redirect_to suitability_fitment_grade_mappings_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    @fitment_grade_mappings = Vger::Resources::Suitability::FitmentGradeMapping.where(:page => params[:page], :per => 50, :methods => [:overall_fitment_grade]).all
  end
end
