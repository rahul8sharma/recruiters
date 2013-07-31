class Suitability::FitsController < ApplicationController
  before_filter :authenticate_user!

  layout "admin"

  def api_resource
    Vger::Resources::Suitability::Fit
  end

  def destroy_all
    api_resource.destroy_all
    redirect_to request.env['HTTP_REFERER'], notice: 'All records deleted'
  end

  def manage
  end

  def import_from_google_drive
    Vger::Resources::Suitability::Fit\
      .import_from_google_drive(params[:import])
    redirect_to suitability_fits_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Suitability::Fit\
      .export_to_google_drive(params[:export]\
                                .merge(:columns => [
                                                    :uid,
                                                    :name
                                                   ],
                                       :pseudo_columns => [:factors]))
    redirect_to suitability_fits_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  # GET /factors
  def index
    @fits = Vger::Resources::Suitability::Fit.where(:page => params[:page], :per => 50).all
  end
end
