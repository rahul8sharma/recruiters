class Suitability::RecommendationsController < ApplicationController
  before_filter :authenticate_user!

  layout "admin"

  def api_resource
    Vger::Resources::Suitability::Recommendation
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  def manage
  end

  def import_from_google_drive
    Vger::Resources::Suitability::Recommendation\
      .import_from_google_drive(params[:import])
    redirect_to suitability_recommendations_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Suitability::Recommendation\
      .export_to_google_drive(params[:export]\
                                .merge(:columns => [
                                                    :uid,
                                                    :candidate_stage,
                                                    :body
                                                   ],
                                       :pseudo_columns => [
                                                           :overall_fitment_grade
                                                          ]))
    redirect_to suitability_recommendations_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    @recommendations = Vger::Resources::Suitability::Recommendation.where(:page => params[:page], :per => 50, :include => [:overall_fitment_grade]).all
  end
end
