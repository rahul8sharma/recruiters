class Suitability::OverallFitmentGradesController < ApplicationController
  before_filter :authenticate_user!
  
  layout "admin"
  
  def manage
  end
  
  def import_from_google_drive
    Vger::Resources::Suitability::OverallFitmentGrade\
      .import_from_google_drive(params[:import])
    redirect_to suitability_overall_fitment_grades_url, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Suitability::OverallFitmentGrade\
      .export_to_google_drive(params[:export].merge(:columns => [:id,:uid, :name]))
    redirect_to suitability_overall_fitment_grades_url, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    @overall_fitment_grades = Vger::Resources::Suitability::OverallFitmentGrade.where(:page => params[:page], :per => 50).all
  end
end
