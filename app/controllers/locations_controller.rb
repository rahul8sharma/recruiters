class LocationsController < ApplicationController
  before_filter :authenticate_user!

  layout "admin"
      
  def manage
  end
  
  def import_from_google_drive
    Vger::Resources::Location\
      .import_from_google_drive(params[:import])
    redirect_to locations_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Location\
      .export_to_google_drive(params[:export].merge(:columns => ["id","name","location_type","parent_id"]))
    redirect_to locations_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def index
    @locations = Vger::Resources::Location.all
  end
end
