class Suitability::FitmentGradesController < ApplicationController
  before_filter :authenticate_user!
  
  layout "admin"
  
  def manage
  end
  
  def import_from_google_drive
    Vger::Resources::Suitability::FitmentGrade\
      .import_from_google_drive(params[:import])
    redirect_to suitability_fitment_grades_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Suitability::FitmentGrade\
      .export_to_google_drive(params[:export].merge(:columns => [:id,:name, :uid, :min_factors_pass_percent, :max_factors_pass_percent]))
    redirect_to suitability_fitment_grades_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    @fitment_grades = Vger::Resources::Suitability::FitmentGrade.where(:page => params[:page], :per => 50).all
  end
end
