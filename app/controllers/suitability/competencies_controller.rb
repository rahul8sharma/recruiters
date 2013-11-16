class Suitability::CompetenciesController < ApplicationController
  before_filter :authenticate_user!

  layout "admin"

  def api_resource
    Vger::Resources::Suitability::Competency
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  def manage
  end

  def import_from_google_drive
    Vger::Resources::Suitability::Competency\
      .import_from_google_drive(params[:import])
    redirect_to suitability_competencies_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Suitability::Competency\
      .export_to_google_drive(params[:export]\
                                .merge(:columns => [
                                                    :uid,
                                                    :name,
                                                    :active
                                                   ],
                                       :pseudo_columns => [:factors, :company]))
    redirect_to suitability_competencies_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    @competencies = Vger::Resources::Suitability::Competency.where(:page => params[:page], :per => 10).all
  end
end
