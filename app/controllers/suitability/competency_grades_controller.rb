class Suitability::CompetencyGradesController < ApplicationController
  before_filter :authenticate_user!

  layout "admin"

  def api_resource
    Vger::Resources::Suitability::CompetencyGrade
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  def manage
  end

  def import_from_google_drive
    Vger::Resources::Suitability::CompetencyGrade\
      .import_from_google_drive(params[:import])
    redirect_to suitability_competency_grades_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Suitability::CompetencyGrade\
      .export_to_google_drive(params[:export]\
                                .merge(:columns => [
                                                    :uid,
                                                    :name,
                                                    :min_factors_pass_percent,
                                                    :max_factors_pass_percent
                                                   ]))
    redirect_to suitability_competency_grades_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    @competency_grades = Vger::Resources::Suitability::CompetencyGrade.where(:page => params[:page], :per => 10).all
  end
end
