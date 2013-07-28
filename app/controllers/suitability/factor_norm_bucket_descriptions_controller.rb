class Suitability::FactorNormBucketDescriptionsController < ApplicationController
  before_filter :authenticate_user!

  layout "admin"

  def api_resource
    Vger::Resources::Suitability::FactorNormBucketDescription
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  def manage
  end

  def import_from_google_drive
    Vger::Resources::Suitability::FactorNormBucketDescription\
      .import_from_google_drive(params[:import])
    redirect_to suitability_factor_norm_bucket_descriptions_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Suitability::FactorNormBucketDescription\
      .export_to_google_drive(params[:export]\
                                .merge(:columns => [
                                                    :uid,
                                                    :description
                                                   ],
                                       :pseudo_columns => [
                                                           :factor,
                                                           :norm_bucket
                                                          ]))
    redirect_to suitability_factor_norm_bucket_descriptions_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    @factor_norm_bucket_descriptions = Vger::Resources::Suitability::FactorNormBucketDescription.where(:page => params[:page], :per => 50, :methods => [:factor, :norm_bucket]).all
  end
end
